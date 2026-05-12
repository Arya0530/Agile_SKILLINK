<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Application;
use App\Models\ProjectHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class PostController extends Controller
{
    // ============================================================
    // Ambil semua postingan untuk tab "For You"
    // GET /api/posts
    // Filter: hanya tampilkan post yang masih aktif (belum ditutup/selesai)
    // ============================================================
    public function index(Request $request)
    {
        $query = Post::latest()
            // Sembunyikan post yang sudah ditutup manual oleh owner
            ->where('is_closed', false)
            // Sembunyikan post yang proyeknya sudah selesai
            ->where('is_completed', false);

        if ($request->has('tag') && $request->tag !== '') {
            $query->where('tags', 'like', '%' . $request->tag . '%');
        }

        $posts = $query->get();

        // Cek apakah user sedang terautentikasi
        $user = auth('sanctum')->user();

        // Tambahkan info apakah user sudah apply ke setiap post
        if ($user) {
            $userAppliedPostIds = $user->applications()->pluck('post_id')->toArray();
            $posts->each(function ($post) use ($userAppliedPostIds) {
                $post->user_already_applied = in_array($post->id, $userAppliedPostIds);
            });
        } else {
            // Jika tidak ada user yang login, set semua ke false
            $posts->each(function ($post) {
                $post->user_already_applied = false;
            });
        }

        return response()->json([
            'success' => true,
            'message' => 'Daftar Postingan Skillink Berhasil Diambil',
            'data'    => $posts
        ]);
    }

    // ============================================================
    // Ambil semua postingan milik user yang sedang login (My Post)
    // GET /api/my-posts  (auth:sanctum)
    // Tampilkan SEMUA status termasuk yang sudah ditutup/selesai
    // ============================================================
    public function myPosts(Request $request)
    {
        $query = $request->user()->posts()->latest();

        if ($request->has('tag') && $request->tag !== '') {
            $query->where('tags', 'like', '%' . $request->tag . '%');
        }

        $posts = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Postingan kamu berhasil diambil!',
            'data'    => $posts,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'post_type'   => 'required|string',
            'content'     => 'required|string',
            'tags'        => 'required|string',
            'max_anggota' => 'nullable|integer|min:1',
        ]);

        $post = $request->user()->posts()->create([
            'author_name'    => $request->user()->name,
            'author_major'   => $request->user()->jurusan ?? 'D3 Teknik Informatika',
            'post_type'      => $request->post_type,
            'content'        => $request->input('content'),
            'tags'           => $request->tags,
            'is_apply'       => 1,
            'is_closed'      => 0,
            'is_completed'   => 0,
            'is_boosted'     => 0,
            'max_anggota'    => $request->input('max_anggota', 0),
            'accepted_count' => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Postingan berhasil mengangkasa!',
            'data'    => $post
        ]);
    }

    // ============================================================
    // [BARU] Tutup Rekrutmen — owner menutup postingan secara manual
    // PUT /api/posts/{id}/close
    // Efek: is_closed = true, is_apply = false
    //       Post hilang dari For You, tetap ada di My Post (label "Ditutup")
    // ============================================================
    public function closeRecruitment(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Postingan nggak ketemu'], 404);
        }

        if ($post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu!'], 403);
        }

        if ($post->is_completed) {
            return response()->json(['success' => false, 'message' => 'Proyek sudah selesai, tidak bisa ditutup ulang.'], 400);
        }

        if ($post->is_closed) {
            return response()->json(['success' => false, 'message' => 'Rekrutmen sudah ditutup sebelumnya.'], 400);
        }

        $post->update([
            'is_closed' => true,
            'is_apply'  => false,
        ]);

        // Auto-reject semua lamaran yang masih pending
        Application::where('post_id', $post->id)
            ->where('status', 'pending')
            ->update(['status' => 'rejected_auto']);

        return response()->json([
            'success' => true,
            'message' => 'Rekrutmen berhasil ditutup!',
            'data'    => $post->fresh()
        ]);
    }

    // ============================================================
    // [BARU] Proyek Selesai — owner menandai proyek sebagai selesai
    // PUT /api/posts/{id}/complete
    // Efek: is_completed = true, completed_at = now()
    //       Post hilang dari For You
    //       Otomatis buat project_history untuk owner + semua accepted member
    // ============================================================
    public function completeProject(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Postingan nggak ketemu'], 404);
        }

        if ($post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu!'], 403);
        }

        if ($post->is_completed) {
            return response()->json(['success' => false, 'message' => 'Proyek sudah pernah diselesaikan sebelumnya.'], 400);
        }

        $completedAt = Carbon::now();

        // Update status post
        $post->update([
            'is_completed' => true,
            'is_closed'    => true,   // otomatis tutup rekrutmen juga
            'is_apply'     => false,
            'completed_at' => $completedAt,
        ]);

        // ── Buat project history untuk semua anggota ──────────────────

        $projectTitle = mb_substr($post->content, 0, 200); // maks 200 karakter
        $leaderName   = $post->author_name;
        $startDate    = $post->created_at->toDateString();
        $endDate      = $completedAt->toDateString();

        // Kumpulkan user_id yang terlibat: owner + semua accepted member
        $memberIds = Application::where('post_id', $post->id)
            ->where('status', 'accepted')
            ->pluck('user_id')
            ->push($post->user_id)   // tambahkan owner
            ->unique()
            ->values();

        foreach ($memberIds as $userId) {
            // ignore jika sudah ada (unique constraint)
            ProjectHistory::firstOrCreate(
                ['user_id' => $userId, 'post_id' => $post->id],
                [
                    'project_title' => $projectTitle,
                    'leader_name'   => $leaderName,
                    'start_date'    => $startDate,
                    'end_date'      => $endDate,
                ]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Proyek berhasil diselesaikan! History otomatis ditambahkan ke semua anggota.',
            'data'    => $post->fresh()
        ]);
    }

    // Fungsi buat nerima lamaran (Easy Apply)
    public function apply(Request $request, $id)
    {
        $post = Post::find($id);
        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Kerjaan nggak ketemu'], 404);
        }

        if ($post->user_id == $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Nggak bisa ngelamar project sendiri kocak!'], 400);
        }

        // Cek apakah postingan masih buka lowongan
        if (!$post->is_apply || $post->is_closed || $post->is_completed) {
            return response()->json(['success' => false, 'message' => 'Maaf, postingan ini sudah tidak menerima lamaran!'], 400);
        }

        $sudahApply = $request->user()->applications()->where('post_id', $id)->exists();
        if ($sudahApply) {
            return response()->json(['success' => false, 'message' => 'Lu udah ngelamar project ini bro!'], 400);
        }

        $request->user()->applications()->create([
            'post_id' => $id,
            'status'  => 'pending'
        ]);

        return response()->json(['success' => true, 'message' => 'Berhasil dikirim!']);
    }

    // Fungsi buat ngambil daftar orang yang ngelamar ke postingan user ini
    public function getMyApplicants(Request $request)
    {
        $posts = $request->user()->posts()->with('applications.user')->get();

        $allApplications = $posts->flatMap(function ($post) {
            return $post->applications
                ->where('status', 'pending')
                ->map(function ($app) use ($post) {
                    return [
                        'application_id'  => $app->id,
                        'post_id'         => $post->id,
                        'post_title'      => $post->content,
                        'max_anggota'     => $post->max_anggota,
                        'accepted_count'  => $post->accepted_count,
                        'applicant_id'    => $app->user->id,
                        'applicant_name'  => $app->user->name,
                        'applicant_major' => $app->user->jurusan,
                        'applicant_no_wa' => $app->user->no_wa,
                        'status'          => $app->status,
                    ];
                });
        });

        return response()->json([
            'success' => true,
            'data'    => $allApplications->values()
        ]);
    }

    // ============================================================
    // Accept atau Reject lamaran (untuk pemilik post)
    // PUT /api/applications/{id}/status
    // ============================================================
    public function updateApplicationStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:accepted,rejected',
        ]);

        $application = Application::with('post')->find($id);

        if (!$application) {
            return response()->json(['success' => false, 'message' => 'Lamaran nggak ketemu'], 404);
        }

        if ($application->post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu, jangan ikut campur!'], 403);
        }

        $application->update(['status' => $request->status]);

        if ($request->status === 'accepted') {
            $post = $application->post;
            $post->increment('accepted_count');
            $post->refresh();

            if ($post->max_anggota > 0 && $post->accepted_count >= $post->max_anggota) {
                $post->update(['is_apply' => 0]);
                Application::where('post_id', $post->id)
                    ->where('status', 'pending')
                    ->update(['status' => 'rejected_auto']);
            }
        }

        $pesan = $request->status === 'accepted'
            ? 'Lamaran berhasil diterima!'
            : 'Lamaran berhasil ditolak.';

        return response()->json([
            'success' => true,
            'message' => $pesan,
            'data'    => $application->fresh()
        ]);
    }

    // History lamaran milik pelamar
    public function getMyApplicationHistory(Request $request)
    {
        $applications = $request->user()
            ->applications()
            ->with('post')
            ->whereIn('status', ['accepted', 'rejected', 'rejected_auto'])
            ->latest()
            ->get()
            ->map(function ($app) {
                $statusLabel = match ($app->status) {
                    'accepted'      => 'Diterima',
                    'rejected'      => 'Ditolak',
                    'rejected_auto' => 'Tertolak Otomatis',
                    default         => $app->status,
                };

                return [
                    'application_id'    => $app->id,
                    'post_title'        => $app->post->content ?? 'Postingan sudah dihapus',
                    'post_owner_name'   => $app->post->author_name ?? '-',
                    'post_owner_major'  => $app->post->author_major ?? '-',
                    'status'            => $app->status,
                    'status_label'      => $statusLabel,
                    'applied_at'        => $app->created_at->format('d M Y'),
                    'updated_at'        => $app->updated_at->format('d M Y'),
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $applications
        ]);
    }

    // History keputusan pemilik post
    public function getMyDecisionHistory(Request $request)
    {
        $posts = $request->user()
            ->posts()
            ->with(['applications' => function ($query) {
                $query->whereIn('status', ['accepted', 'rejected', 'rejected_auto'])->with('user');
            }])
            ->get();

        $decisionHistory = $posts->flatMap(function ($post) {
            return $post->applications->map(function ($app) use ($post) {
                $statusLabel = match ($app->status) {
                    'accepted'      => 'Diterima',
                    'rejected'      => 'Ditolak',
                    'rejected_auto' => 'Tertolak Otomatis',
                    default         => $app->status,
                };

                return [
                    'application_id'   => $app->id,
                    'post_title'       => $post->content,
                    'applicant_id'     => $app->user->id,
                    'applicant_name'   => $app->user->name,
                    'applicant_major'  => $app->user->jurusan ?? '-',
                    'applicant_no_wa'  => $app->user->no_wa ?? null,
                    'status'           => $app->status,
                    'status_label'     => $statusLabel,
                    'decided_at'       => $app->updated_at->format('d M Y'),
                ];
            });
        })->sortByDesc('decided_at')->values();

        return response()->json([
            'success' => true,
            'data'    => $decisionHistory
        ]);
    }

    // Fungsi buat hapus postingan sendiri
    public function destroy(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Postingan nggak ketemu'], 404);
        }

        if ($post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Heh, mau ngapus postingan orang lu?'], 403);
        }

        $post->delete();

        return response()->json(['success' => true, 'message' => 'Postingan berhasil dihapus!']);
    }

    // Fungsi buat ngedit postingan sendiri
    public function update(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Postingan nggak ketemu'], 404);
        }

        if ($post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu kocak!'], 403);
        }

        $request->validate([
            'post_type'   => 'required|string',
            'content'     => 'required|string',
            'tags'        => 'required|string',
            'max_anggota' => 'nullable|integer|min:1',
        ]);

        $updateData = [
            'post_type' => $request->post_type,
            'content'   => $request->input('content'),
            'tags'      => $request->tags,
        ];

        if ($request->has('max_anggota')) {
            $updateData['max_anggota'] = $request->input('max_anggota', 0);
            $newMax = (int) $request->input('max_anggota', 0);
            if ($newMax === 0 || $newMax > $post->accepted_count) {
                $updateData['is_apply'] = 1;
            }
        }

        $post->update($updateData);

        return response()->json(['success' => true, 'message' => 'Postingan berhasil diupdate!', 'data' => $post->fresh()]);
    }
}
