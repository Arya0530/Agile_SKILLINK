<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Post;

class ProfileController extends Controller
{
    // 1. Fungsi buat ngambil data Profil lengkap (User + Skill + Project + Project History)
    public function getProfile(Request $request)
    {
        // Narik data user yang lagi login, sekalian bawa relasi skills, projects,
        // dan project histories (portofolio otomatis dari proyek selesai)
        $user = $request->user()->load(['skills', 'projects', 'projectHistories']);

        // Format project histories biar lebih enak dikonsumsi di Flutter
        $formattedHistories = $user->projectHistories->map(function ($h) {
            return [
                'id'            => $h->id,
                'post_id'       => $h->post_id,
                'project_title' => $h->project_title,
                'leader_name'   => $h->leader_name,
                'start_date'    => $h->start_date,
                'end_date'      => $h->end_date,
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => [
                'id'               => $user->id,
                'name'             => $user->name,
                'email'            => $user->email,
                'jurusan'          => $user->jurusan,
                'no_wa'            => $user->no_wa,
                'skills'           => $user->skills,
                'projects'         => $user->projects,         // manual projects (tetap ada)
                'project_histories' => $formattedHistories,    // [BARU] auto portfolio
            ]
        ]);
    }

    // [BARU] Fungsi buat update profil user (nama, email, no_wa, jurusan)
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name'    => 'required|string|max:255',
            'email'   => 'required|email|unique:users,email,' . $request->user()->id,
            'no_wa'   => 'required|string|max:20',
            'jurusan' => 'required|string|max:255',
            'password' => 'nullable|string|min:8|confirmed',
        ]);

        $user = $request->user();
        $oldName = $user->name;
        $newName = $request->name;
        
        // Update profil user
        $user->name = $newName;
        $user->email = $request->email;
        $user->no_wa = $request->no_wa;
        $user->jurusan = $request->jurusan;

        // Update password jika ada dan valid
        if ($request->filled('password')) {
            $user->password = bcrypt($request->password);
        }

        $user->save();

        // [BARU] Update semua posts user dengan nama terbaru jika nama berubah
        if ($oldName !== $newName) {
            Post::where('user_id', $user->id)
                ->update(['author_name' => $newName]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui!',
            'data'    => [
                'id'       => $user->id,
                'name'     => $user->name,
                'email'    => $user->email,
                'jurusan'  => $user->jurusan,
                'no_wa'    => $user->no_wa,
            ]
        ]);
    }

    // 2. Fungsi buat nambahin Skill baru
    public function addSkill(Request $request)
    {
        $request->validate([
            'name' => 'required|string'
        ]);

        $skill = $request->user()->skills()->create([
            'name' => $request->name
        ]);

        return response()->json(['success' => true, 'message' => 'Skill berhasil ditambah!', 'data' => $skill]);
    }

    // 3. Fungsi buat nambahin Project baru (manual)
    public function addProject(Request $request)
    {
        $request->validate([
            'title'       => 'required|string',
            'role'        => 'required|string',
            'description' => 'required|string',
        ]);

        $project = $request->user()->projects()->create([
            'title'       => $request->title,
            'role'        => $request->role,
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

    // Fungsi hapus project (manual)
    public function deleteProject(Request $request, $id)
    {
        $request->user()->projects()->where('id', $id)->delete();
        return response()->json(['success' => true]);
    }
}
