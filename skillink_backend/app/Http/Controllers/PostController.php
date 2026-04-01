<?php

namespace App\Http\Controllers;

use App\Models\Post; // Jangan lupa tambahin ini di atas biar dia kenal tabel Post
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index()
    {
        // Ngambil semua data postingan, diurutin dari yang paling baru
        $posts = Post::latest()->get();

        // Kirim datanya dalam bentuk JSON
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

        // 👇 INI MAGIC-NYA: Kita pakai relasi user()->posts() biar user_id otomatis keisi!
        $post = $request->user()->posts()->create([
            'author_name' => $request->user()->name, // Otomatis ngambil nama lu dari database!
            'author_major' => $request->user()->jurusan ?? 'D3 Teknik Informatika', // Otomatis ngambil jurusan lu
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
        // 1. Cari postingan yang mau dilamar ada atau nggak
        $post = \App\Models\Post::find($id);
        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Kerjaan nggak ketemu'], 404);
        }

        // 2. Cegah orang ngelamar project-nya sendiri (biar nggak aneh)
        if ($post->user_id == $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Nggak bisa ngelamar project sendiri kocak!'], 400);
        }

        // 3. Cegah orang spam klik "Apply" berkali-kali di satu project
        $sudahApply = $request->user()->applications()->where('post_id', $id)->exists();
        if ($sudahApply) {
            return response()->json(['success' => false, 'message' => 'Lu udah ngelamar project ini bro!'], 400);
        }

        // 4. Catat surat lamarannya ke database
        $request->user()->applications()->create([
            'post_id' => $id,
            'status' => 'pending' // Status awal pasti pending (menunggu)
        ]);

        return response()->json(['success' => true, 'message' => 'Berhasil dikirim!']);
    }
// Fungsi buat ngambil daftar orang yang ngelamar ke postingan user ini
    public function getMyApplicants(Request $request)
    {
        // Cari semua postingan milik user yang lagi login
        // Terus ambil data orang yang ngelamar (applications) beserta profil pelamarnya (user)
        $posts = $request->user()->posts()->with('applications.user')->get();
        
        // Kumpulin semua lamaran dari semua postingan biar gampang ditampilin di Flutter
        $allApplications = $posts->flatMap(function ($post) {
            return $post->applications->map(function ($app) use ($post) {
                return [
                    'application_id' => $app->id,
                    'post_title' => $post->content, // Ngambil isi postingan sebagai judul
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
            'data' => $allApplications
        ]);
    }
    // Fungsi buat hapus postingan sendiri
    public function destroy(Request $request, $id)
    {
        $post = \App\Models\Post::find($id);

        if (!$post) {
            return response()->json(['success' => false, 'message' => 'Postingan nggak ketemu'], 404);
        }

        // Satpam: Pastiin yang mau hapus adalah yang bikin postingannya
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

        // Satpam: Cuma yang bikin yang boleh ngedit
        if ($post->user_id != $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Bukan postingan lu kocak!'], 403);
        }

        // Validasi data baru
        $request->validate([
            'post_type' => 'required|string',
            'content' => 'required|string',
            'tags' => 'required|string',
        ]);

        // Simpan perubahan ke database
        $post->update([
            'post_type' => $request->post_type,
            'content' => $request->input('content'),
            'tags' => $request->tags,
        ]);

        return response()->json(['success' => true, 'message' => 'Postingan berhasil diupdate!']);
    }
}