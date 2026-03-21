<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ProfileController extends Controller
{
    // 1. Fungsi buat ngambil data Profil lengkap (User + Skill + Project)
    public function getProfile(Request $request)
    {
        // Narik data user yang lagi login, sekalian bawa relasi skills dan projects-nya
        $user = $request->user()->load(['skills', 'projects']);
        
        return response()->json([
            'success' => true,
            'data' => $user
        ]);
    }

    // 2. Fungsi buat nambahin Skill baru
    public function addSkill(Request $request)
    {
        $request->validate([
            'name' => 'required|string'
        ]);

        // Otomatis nyimpen skill buat user yang lagi login
        $skill = $request->user()->skills()->create([
            'name' => $request->name
        ]);

        return response()->json(['success' => true, 'message' => 'Skill berhasil ditambah!', 'data' => $skill]);
    }

    // 3. Fungsi buat nambahin Project baru
    public function addProject(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'role' => 'required|string',
            'description' => 'required|string',
        ]);

        // Otomatis nyimpen project buat user yang lagi login
        $project = $request->user()->projects()->create([
            'title' => $request->title,
            'role' => $request->role,
            'description' => $request->description,
        ]);

        return response()->json(['success' => true, 'message' => 'Project berhasil ditambah!', 'data' => $project]);
    }
    // Fungsi hapus skill
    public function deleteSkill(Request $request, $id)
    {
        $request->user()->skills()->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }

    // Fungsi hapus project
    public function deleteProject(Request $request, $id)
    {
        $request->user()->projects()->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }
}