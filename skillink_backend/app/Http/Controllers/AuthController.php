<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // Fungsi buat Daftar Akun (Register)
    public function register(Request $request)
    {
        // 1. Cek apakah isian form dari Flutter udah lengkap
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        // 2. Masukin data ke database (password wajib diacak biar aman)
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'jurusan' => $request->jurusan,
        ]);

        // 3. Bikin tiket masuk (Token Sanctum)
        $token = $user->createToken('auth_token')->plainTextToken;

        // 4. Balikin info sukses ke HP lu
        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran Berhasil!',
            'data' => $user,
            'token' => $token
        ]);
    }

    // Fungsi buat Masuk (Login)
    public function login(Request $request)
    {
        // 1. Cari user berdasarkan email
        $user = User::where('email', $request->email)->first();

        // 2. Cek apakah user ada DAN password-nya bener
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau Password salah, bro!'
            ], 401);
        }

        // 3. Bikin tiket masuk (Token Sanctum)
        $token = $user->createToken('auth_token')->plainTextToken;

        // 4. Kasih izin masuk
        return response()->json([
            'success' => true,
            'message' => 'Login Berhasil!',
            'data' => $user,
            'token' => $token
        ]);
    }
}