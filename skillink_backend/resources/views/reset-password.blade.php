<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Reset Password - SKILLINK</title>

    <style>

        *{
            margin:0;
            padding:0;
            box-sizing:border-box;
            font-family: Arial, sans-serif;
        }

        body{
            min-height:100vh;
            background:#f4f7fb;
            overflow:hidden;
            position:relative;
            display:flex;
            justify-content:center;
            align-items:center;
            padding:20px;
        }

        /* DEKORASI BULATAN */
        .circle-top{
            position:absolute;
            width:300px;
            height:300px;
            background:rgba(0,119,181,0.08);
            border-radius:50%;
            top:-120px;
            right:-100px;
        }

        .circle-bottom{
            position:absolute;
            width:280px;
            height:280px;
            background:rgba(0,119,181,0.05);
            border-radius:50%;
            bottom:-120px;
            left:-100px;
        }

        .container{
            width:100%;
            max-width:420px;
            position:relative;
            z-index:2;
        }

        .icon-box{
            width:95px;
            height:95px;
            border-radius:50%;
            background:rgba(0,119,181,0.1);
            display:flex;
            justify-content:center;
            align-items:center;
            margin:0 auto 28px auto;
            font-size:42px;
            color:#0077B5;
        }

        .card{
            background:white;
            border-radius:24px;
            padding:34px 26px;
            box-shadow:0 12px 30px rgba(0,0,0,0.08);
        }

        .logo{
            text-align:center;
            font-size:34px;
            font-weight:bold;
            color:#0077B5;
            margin-bottom:10px;
        }

        .subtitle{
            text-align:center;
            color:#666;
            font-size:15px;
            line-height:1.6;
            margin-bottom:34px;
        }

        .input-group{
            margin-bottom:18px;
        }

        .input-group label{
            display:block;
            margin-bottom:8px;
            font-size:14px;
            font-weight:600;
            color:#444;
        }

        .input-group input{
            width:100%;
            padding:15px;
            border:none;
            border-radius:14px;
            background:#f7f9fc;
            font-size:15px;
            outline:none;
            transition:0.2s;
        }

        .input-group input:focus{
            border:2px solid #0077B5;
            background:white;
            box-shadow:0 0 0 4px rgba(0,119,181,0.12);
        }

        .email-box{
            color:#666;
        }

        .btn{
            width:100%;
            padding:15px;
            border:none;
            border-radius:14px;
            background:#0077B5;
            color:white;
            font-size:16px;
            font-weight:bold;
            cursor:pointer;
            transition:0.2s;
            margin-top:10px;
        }

        .btn:hover{
            opacity:0.92;
            transform:translateY(-1px);
        }

        .footer{
            text-align:center;
            margin-top:22px;
            font-size:12px;
            color:#888;
        }

        @media(max-width:480px){

            .card{
                padding:28px 22px;
                border-radius:20px;
            }

            .logo{
                font-size:30px;
            }

            .subtitle{
                font-size:14px;
            }

        }

    </style>
</head>

<body>

    <!-- DEKORASI -->
    <div class="circle-top"></div>
    <div class="circle-bottom"></div>

    <div class="container">

        <div class="icon-box">
            🔒
        </div>

        <div class="card">

            <div class="logo">
                SKILLINK
            </div>

            <div class="subtitle">
                Buat password baru untuk akun kamu dan lanjutkan kolaborasi tanpa drama lupa password lagi.
            </div>

            <form method="POST" action="{{ url('/reset-password') }}">
                @csrf

                <input
                    type="hidden"
                    name="token"
                    value="{{ $token }}"
                >

                <div class="input-group">

                    <label>Email</label>

                    <input
                        type="email"
                        name="email"
                        value="{{ request()->email }}"
                        readonly
                        class="email-box"
                    >

                </div>

                <div class="input-group">

                    <label>Password Baru</label>

                    <input
                        type="password"
                        name="password"
                        placeholder="Masukkan password baru"
                        required
                    >

                </div>

                <div class="input-group">

                    <label>Konfirmasi Password</label>

                    <input
                        type="password"
                        name="password_confirmation"
                        placeholder="Ulangi password baru"
                        required
                    >

                </div>

                <button type="submit" class="btn">
                    Reset Password
                </button>

            </form>

            <div class="footer">
                © SKILLINK 2026
            </div>

        </div>

    </div>

</body>
</html>
