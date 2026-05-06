<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use App\Models\User;

Route::get('/', function () {
    return view('welcome');
});

// WEB RESET PASSWORD
Route::get('/reset-password/{token}', function (
    Request $request,
    $token
) {

    return view('reset-password', [
        'token' => $token,
        'email' => $request->email
    ]);

})->name('password.reset');

// PROSES RESET PASSWORD
Route::post('/reset-password', function (Request $request) {

    $request->validate([
        'token' => 'required',
        'email' => 'required|email',
        'password' => 'required|min:6|confirmed',
    ]);

    $status = Password::reset(

        $request->only(
            'email',
            'password',
            'password_confirmation',
            'token'
        ),

        function (User $user, string $password) {

            $user->forceFill([
                'password' => Hash::make($password)
            ])->save();

        }

    );

    // Kalau berhasil
    if ($status == Password::PASSWORD_RESET) {

        return "
            <h2 style='font-family:Arial;text-align:center;margin-top:50px;color:green;'>
                Password berhasil direset!
            </h2>
        ";

    }

    // Kalau gagal
    return "
        <h2 style='font-family:Arial;text-align:center;margin-top:50px;color:red;'>
            Reset password gagal!
        </h2>
    ";

});
