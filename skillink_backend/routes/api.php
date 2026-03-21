<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\AuthController;

// Bikin URL API: localhost:8000/api/posts
Route::get('/posts', [PostController::class, 'index']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/posts', [App\Http\Controllers\PostController::class, 'store']);


// Rute-rute yang WAJIB LOGIN (Dilindungi Satpam Sanctum)
Route::middleware('auth:sanctum')->group(function () {
 Route::delete('/profile/skills/{id}', [ProfileController::class, 'deleteSkill']);
Route::delete('/profile/projects/{id}', [ProfileController::class, 'deleteProject']);
    
    // Rute buat fitur Profil
    Route::get('/profile', [ProfileController::class, 'getProfile']);
    Route::post('/profile/skills', [ProfileController::class, 'addSkill']);
    Route::post('/profile/projects', [ProfileController::class, 'addProject']);
    
});