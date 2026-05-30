<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ForgotPasswordController;

// ─── PUBLIC ROUTES ────────────────────────────────────────────────────────────

// For You feed — hanya tampilkan post aktif (is_closed=false, is_completed=false)
Route::get('/posts', [PostController::class, 'index']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/reset-password-direct', [AuthController::class, 'resetPasswordDirect']);
Route::post('/forgot-password', [ForgotPasswordController::class, 'forgot']);

// ─── PROTECTED ROUTES (Wajib Login) ──────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function () {

    // ── Profile ───────────────────────────────────────────────────────────────
    Route::get('/profile', [ProfileController::class, 'getProfile']);
    Route::put('/profile', [ProfileController::class, 'updateProfile']);
    Route::post('/profile/skills', [ProfileController::class, 'addSkill']);
    Route::delete('/profile/skills/{id}', [ProfileController::class, 'deleteSkill']);
    Route::post('/profile/projects', [ProfileController::class, 'addProject']);
    Route::delete('/profile/projects/{id}', [ProfileController::class, 'deleteProject']);
    Route::put('/profile/projects/{id}', [ProfileController::class, 'updateProject']);

    // ── Posts ─────────────────────────────────────────────────────────────────
    Route::get('/my-posts', [PostController::class, 'myPosts']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::put('/posts/{id}', [PostController::class, 'update']);
    Route::delete('/posts/{id}', [PostController::class, 'destroy']);

    // [BARU] Tutup Rekrutmen — post hilang dari For You, label "Ditutup" di My Post
    Route::put('/posts/{id}/close', [PostController::class, 'closeRecruitment']);

    // [BARU] Proyek Selesai — label berubah + auto-buat project history semua anggota
    Route::put('/posts/{id}/complete', [PostController::class, 'completeProject']);

    // ── Applications ──────────────────────────────────────────────────────────
    Route::post('/posts/{id}/apply', [PostController::class, 'apply']);
    Route::get('/my-applicants', [PostController::class, 'getMyApplicants']);
    Route::put('/applications/{id}/status', [PostController::class, 'updateApplicationStatus']);
    Route::get('/my-application-history', [PostController::class, 'getMyApplicationHistory']);
    Route::get('/my-decision-history', [PostController::class, 'getMyDecisionHistory']);

    // ── Public profile orang lain ─────────────────────────────────────────────
    Route::get('/users/{id}/profile', function ($id) {
        $user = \App\Models\User::with(['skills', 'projects', 'projectHistories'])->find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User nggak ketemu'], 404);
        }
        return response()->json(['success' => true, 'data' => $user]);
    });
});
