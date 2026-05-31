<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;

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
            'no_wa' => 'required|regex:/^[0-9]+$/|min:10|max:13|unique:users',
            'jurusan' => 'required|string',
        ], [
            'no_wa.required' => 'Nomor WhatsApp wajib diisi!',
            'no_wa.regex' => 'Nomor WhatsApp hanya boleh berisi angka (tidak ada huruf/simbol)!',
            'no_wa.min' => 'Nomor WhatsApp minimal 10 digit!',
            'no_wa.max' => 'Nomor WhatsApp maksimal 13 digit!',
            'no_wa.unique' => 'Nomor WhatsApp sudah terdaftar, gunakan nomor lain!',
            'jurusan.required' => 'Jurusan wajib dipilih!',
        ]);

        // 2. Masukin data ke database (password wajib diacak biar aman)
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'jurusan' => $request->jurusan,
            'no_wa' => $request->no_wa,
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

    // Fungsi buat Reset Password
    public function resetPasswordDirect(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil direset'
        ]);
    }
}
