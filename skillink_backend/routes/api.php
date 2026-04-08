<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\AuthController;

// Bikin URL API: localhost:8000/api/posts
Route::get('/posts', [PostController::class, 'index']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
// Rute forgot password
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

// Rute-rute yang WAJIB LOGIN (Dilindungi Satpam Sanctum)
Route::middleware('auth:sanctum')->group(function () {
Route::delete('/profile/skills/{id}', [ProfileController::class, 'deleteSkill']);
Route::delete('/profile/projects/{id}', [ProfileController::class, 'deleteProject']);
Route::post('/posts/{id}/apply', [PostController::class, 'apply']);
Route::get('/my-applicants', [PostController::class, 'getMyApplicants']);
Route::post('/posts', [App\Http\Controllers\PostController::class, 'store']);
Route::delete('/posts/{id}', [PostController::class, 'destroy']);
Route::put('/posts/{id}', [PostController::class, 'update']);
// Rute jalan pintas buat ngintip profil orang + skill + project-nya
Route::get('/users/{id}/profile', function($id) {
        $user = \App\Models\User::with(['skills', 'projects'])->find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User nggak ketemu'], 404);
        }
        return response()->json(['success' => true, 'data' => $user]);
    });

    // Rute buat fitur Profil
    Route::get('/profile', [ProfileController::class, 'getProfile']);
    Route::post('/profile/skills', [ProfileController::class, 'addSkill']);
    Route::post('/profile/projects', [ProfileController::class, 'addProject']);

});
