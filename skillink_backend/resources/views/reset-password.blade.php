<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - SKILLINK</title>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        html {
            overflow-x: hidden;
        }

        body {
            min-height: 100vh;
            background: #f4f7fb;
            overflow-x: hidden;
            overflow-y: auto;
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .circle-top {
            position: absolute;
            width: 300px;
            height: 300px;
            background: rgba(0, 119, 181, 0.08);
            border-radius: 50%;
            top: -120px;
            right: -100px;
        }

        .circle-bottom {
            position: absolute;
            width: 280px;
            height: 280px;
            background: rgba(0, 119, 181, 0.05);
            border-radius: 50%;
            bottom: -120px;
            left: -100px;
        }

        .container {
            width: 100%;
            max-width: 420px;
            position: relative;
            z-index: 2;
        }

        .icon-box {
            width: 95px;
            height: 95px;
            border-radius: 50%;
            background: rgba(0, 119, 181, 0.1);
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0 auto 28px auto;
            font-size: 42px;
            color: #0077B5;
        }

        .card {
            background: white;
            border-radius: 24px;
            padding: 34px 26px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.08);
        }

        .logo {
            text-align: center;
            font-size: 34px;
            font-weight: bold;
            color: #0077B5;
            margin-bottom: 10px;
        }

        .subtitle {
            text-align: center;
            color: #666;
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 34px;
        }

        .input-group {
            margin-bottom: 18px;
        }

        .input-group label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 600;
            color: #444;
        }

        .input-group input {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 14px;
            background: #f7f9fc;
            font-size: 15px;
            outline: none;
            transition: 0.2s;
        }

        .input-group input:focus {
            border: 2px solid #0077B5;
            background: white;
            box-shadow: 0 0 0 4px rgba(0, 119, 181, 0.12);
        }

        .email-box {
            color: #666;
        }

        .input-wrapper {
            position: relative;
        }

        .input-wrapper input {
            width: 100%;
            padding: 15px;
            padding-right: 45px;
            border: none;
            border-radius: 14px;
            background: #f7f9fc;
            font-size: 15px;
            outline: none;
            transition: 0.2s;
        }

        .input-wrapper input:focus {
            border: 2px solid #0077B5;
            background: white;
            box-shadow: 0 0 0 4px rgba(0, 119, 181, 0.12);
        }

        .toggle-eye {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            font-size: 16px;
            color: #aaa;
            user-select: none;
            transition: color 0.2s;
        }

        .toggle-eye:hover {
            color: #0077B5;
        }

        .btn {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 14px;
            background: #0077B5;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.2s;
            margin-top: 10px;
        }

        .btn:hover {
            opacity: 0.92;
            transform: translateY(-1px);
        }

        .footer {
            text-align: center;
            margin-top: 22px;
            font-size: 12px;
            color: #888;
        }

        .swal2-container {
            z-index: 9999 !important;
        }

        .swal2-popup {
            border-radius: 20px !important;
        }

        @media(max-width:480px) {
            .card {
                padding: 28px 22px;
                border-radius: 20px;
            }

            .logo {
                font-size: 30px;
            }

            .subtitle {
                font-size: 14px;
            }

            .swal2-popup {
                border-radius: 20px !important;
            }

            .swal2-title {
                font-size: 28px !important;
            }

            .swal2-html-container {
                font-size: 16px !important;
            }

            .skillink-popup {
                border-radius: 20px !important;
            }

            .skillink-title {
                font-size: 28px !important;
            }

            .skillink-text {
                font-size: 16px !important;
                line-height: 1.5 !important;
                margin-top: 5px !important;
            }
        }
    </style>
</head>

<body>

    <div class="circle-top"></div>
    <div class="circle-bottom"></div>

    <div class="container">

        <div class="icon-box">
            <i class="fa-solid fa-lock"></i>
        </div>

        <div class="card">

            <div class="logo">
                SKILLINK
            </div>

            <div class="subtitle">
                Buat password baru untuk akun kamu dan lanjutkan kolaborasi tanpa drama lupa password lagi.
            </div>

            <form method="POST" action="{{ url('/reset-password') }}" id="resetForm">
                @csrf

                <input type="hidden" name="token" value="{{ $token }}">

                <div class="input-group">
                    <label>Email</label>
                    <input type="email" name="email" value="{{ request()->email }}" readonly class="email-box">
                </div>

                <div class="input-group">
                    <label>Password Baru</label>
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" placeholder="Masukkan password baru"
                            required>
                        <span class="toggle-eye" onclick="togglePassword('password', this)">
                            <i class="fa-regular fa-eye"></i>
                        </span>
                    </div>
                </div>

                <div class="input-group">
                    <label>Konfirmasi Password</label>
                    <div class="input-wrapper">
                        <input type="password" id="password_confirmation" name="password_confirmation"
                            placeholder="Ulangi password baru" required>
                        <span class="toggle-eye" onclick="togglePassword('password_confirmation', this)">
                            <i class="fa-regular fa-eye"></i>
                        </span>
                    </div>
                </div>

                <button type="button" class="btn" onclick="confirmReset()">
                    Reset Password
                </button>

            </form>

            <div class="footer">
                © SKILLINK 2026
            </div>

        </div>

    </div>

    <script>
        function togglePassword(fieldId, span) {
            const input = document.getElementById(fieldId);
            const icon = span.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        function confirmReset() {
            Swal.fire({
                title: 'Konfirmasi Password',
                html: `Apakah Anda yakin ingin mengganti password?`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Ya',
                cancelButtonText: 'Batal',
                confirmButtonColor: '#0077B5',
                cancelButtonColor: '#6c757d',
                width: 320,
                padding: '1.5em',
                customClass: {
                    popup: 'skillink-popup',
                    title: 'skillink-title',
                    htmlContainer: 'skillink-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById('resetForm').submit();
                }
            });
        }
    </script>

</body>

</html>
