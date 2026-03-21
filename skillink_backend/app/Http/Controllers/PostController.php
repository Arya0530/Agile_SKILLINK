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

        $post = \App\Models\Post::create([
            'author_name' => $request->input('author_name'),
            'author_major' => 'D3 Teknik Informatika',
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

}