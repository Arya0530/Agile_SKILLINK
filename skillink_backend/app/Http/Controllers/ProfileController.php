<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

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
