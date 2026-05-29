<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Password;
use App\Models\User;

class ForgotPasswordController extends Controller
{
    public function forgot(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where(
            'email',
            $request->email
        )->first();

        if (!$user) {

            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar',
            ], 404);

        }

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {

            return response()->json([
                'success' => true,
                'message' => 'Link reset password berhasil dikirim',
            ]);

        }

        return response()->json([
            'success' => false,
            'message' => 'Gagal mengirim email reset password',
        ], 400);
    }
}
