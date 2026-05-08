<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Application;
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index(Request $request)
    {
        $query = Post::latest();

        // Kalau ada ?tag=xxx dari Flutter, filter berdasarkan kolom tags
        if ($request->has('tag') && $request->tag !== '') {
            $query->where('tags', 'like', '%' . $request->tag . '%');
        }

        $posts = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar Postingan Skillink Berhasil Diambil',
            'data'    => $posts
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'post_type' => 'required|string',
            'content' => 'required|string',
            'tags' => 'required|string',
        ]);

        $post = $request->user()->posts()->create([
            'author_name' => $request->user()->name,
            'author_major' => $request->user()->jurusan ?? 'D3 Teknik Informatika',
            'post_type' => $request->post_type,
            'content' => $request->input('content'),
            'tags' => $request->tags,
            'is_apply' => 1,
            'is_boosted' => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Postingan berhasil mengangkasa!',
            'data' => $post
        ]);
    }

    // Fungsi buat nerima lamaran (Easy Apply)
    public function apply(Request $request, $id)
    {
        $post = \App\Models\Post::find($id);
        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Kerjaan nggak ketemu'], 404);
        }

        if ($post->user_id == $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Nggak bisa ngelamar project sendiri kocak!'], 400);
        }

        $sudahApply = $request->user()->applications()->where('post_id', $id)->exists();
        if ($sudahApply) {
            return response()->json(['success' => false, 'message' => 'Lu udah ngelamar project ini bro!'], 400);
        }

        $request->user()->applications()->create([
            'post_id' => $id,
            'status' => 'pending'
        ]);

        return response()->json(['success' => true, 'message' => 'Berhasil dikirim!']);
    }

    // Fungsi buat ngambil daftar orang yang ngelamar ke postingan user ini
    public function getMyApplicants(Request $request)
    {
        $posts = $request->user()->posts()->with('applications.user')->get();

        // Hanya ambil yang statusnya masih 'pending' supaya yang udah di-acc/reject hilang dari tab Permintaan
        $allApplications = $posts->flatMap(function ($post) {
            return $post->applications
                ->where('status', 'pending')
                ->map(function ($app) use ($post) {
                    return [
                        'application_id' => $app->id,
                        'post_title' => $post->content,
                        'applicant_id' => $app->user->id,
                        'applicant_name' => $app->user->name,
                        'applicant_major' => $app->user->jurusan,
                        'applicant_no_wa' => $app->user->no_wa,
                        'status' => $app->status,
                    ];
                });
        });

        return response()->json([
            'success' => true,
            'data' => $allApplications->values()
        ]);
    }

    // ============================================================
    // [BARU] Fungsi buat owner post accept/reject lamaran
    // PUT /api/applications/{id}/status
    // Body: { "status": "accepted" } atau { "status": "rejected" }
    // ============================================================
    public function updateApplicationStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:accepted,rejected',
        ]);

        // Cari lamaran yang dimaksud
        $application = Application::with('post')->find($id);

        if (!$application) {
            return response()->json(['success' => false, 'message' => 'Lamaran nggak ketemu'], 404);
        }

        // Satpam: Pastiin yang mau update adalah pemilik postingan, bukan orang random
        if ($application->post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu, jangan ikut campur!'], 403);
        }

        // Update status lamaran
        $application->update(['status' => $request->status]);

        $pesan = $request->status === 'accepted'
            ? 'Lamaran berhasil diterima!'
            : 'Lamaran berhasil ditolak.';

        return response()->json([
            'success' => true,
            'message' => $pesan,
            'data' => $application
        ]);
    }

    // ============================================================
    // [BARU] Fungsi buat pelamar ngecek history lamaran mereka sendiri
    // GET /api/my-application-history
    // Nampilin semua lamaran yang statusnya accepted atau rejected
    // ============================================================
    public function getMyApplicationHistory(Request $request)
    {
        // Ambil semua lamaran milik user yang lagi login, beserta data postingannya
        $applications = $request->user()
            ->applications()
            ->with('post')
            ->whereIn('status', ['accepted', 'rejected'])
            ->latest()
            ->get()
            ->map(function ($app) {
                return [
                    'application_id' => $app->id,
                    'post_title' => $app->post->content ?? 'Postingan sudah dihapus',
                    'post_owner_name' => $app->post->author_name ?? '-',
                    'post_owner_major' => $app->post->author_major ?? '-',
                    'status' => $app->status,
                    'applied_at' => $app->created_at->format('d M Y'),
                    'updated_at' => $app->updated_at->format('d M Y'),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $applications
        ]);
    }

    // ============================================================
    // [BARU] History keputusan pemilik post (yang sudah di-acc/reject)
    // GET /api/my-decision-history
    // Nampilin semua lamaran yang sudah ditindak oleh user (sebagai pemilik post)
    // Kalau accepted → ada no_wa pelamar buat dihubungi lagi
    // ============================================================
    public function getMyDecisionHistory(Request $request)
    {
        // Ambil semua post milik user, lalu tarik lamaran yang sudah acc/reject
        $posts = $request->user()
            ->posts()
            ->with(['applications' => function ($query) {
                $query->whereIn('status', ['accepted', 'rejected'])->with('user');
            }])
            ->get();

        $decisionHistory = $posts->flatMap(function ($post) {
            return $post->applications->map(function ($app) use ($post) {
                return [
                    'application_id'   => $app->id,
                    'post_title'       => $post->content,
                    'applicant_id'     => $app->user->id,
                    'applicant_name'   => $app->user->name,
                    'applicant_major'  => $app->user->jurusan ?? '-',
                    'applicant_no_wa'  => $app->user->no_wa ?? null, // buat tombol WA di history
                    'status'           => $app->status,
                    'decided_at'       => $app->updated_at->format('d M Y'),
                ];
            });
        })->sortByDesc('decided_at')->values();

        return response()->json([
            'success' => true,
            'data' => $decisionHistory
        ]);
    }

    // Fungsi buat hapus postingan sendiri
    public function destroy(Request $request, $id)
    {
        $post = \App\Models\Post::find($id);

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
        $post = \App\Models\Post::find($id);

        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Postingan nggak ketemu'], 404);
        }

        if ($post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu kocak!'], 403);
        }

        $request->validate([
            'post_type' => 'required|string',
            'content' => 'required|string',
            'tags' => 'required|string',
        ]);

        $post->update([
            'post_type' => $request->post_type,
            'content' => $request->input('content'),
            'tags' => $request->tags,
        ]);

        return response()->json(['success' => true, 'message' => 'Postingan berhasil diupdate!']);
    }
}
