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
            background:#f3f2ef;
            display:flex;
            justify-content:center;
            align-items:center;
            min-height:100vh;
            padding:20px;
        }

        .container{
            width:100%;
            max-width:400px;
        }

        .card{
            background:white;
            border-radius:18px;
            padding:32px 24px;
            box-shadow:0 4px 20px rgba(0,0,0,0.08);
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
            font-size:14px;
            margin-bottom:30px;
        }

        .input-group{
            margin-bottom:18px;
        }

        .input-group label{
            display:block;
            margin-bottom:8px;
            font-size:14px;
            color:#444;
            font-weight:600;
        }

        .input-group input{
            width:100%;
            padding:14px;
            border:1px solid #dcdcdc;
            border-radius:12px;
            font-size:15px;
            outline:none;
            transition:0.2s;
        }

        .input-group input:focus{
            border-color:#0077B5;
            box-shadow:0 0 0 3px rgba(0,119,181,0.15);
        }

        .email-box{
            background:#f7f7f7;
            color:#666;
        }

        .btn{
            width:100%;
            padding:14px;
            border:none;
            border-radius:12px;
            background:#0077B5;
            color:white;
            font-size:16px;
            font-weight:bold;
            cursor:pointer;
            transition:0.2s;
        }

        .btn:hover{
            opacity:0.9;
        }

        .footer{
            text-align:center;
            margin-top:20px;
            font-size:13px;
            color:#888;
        }

        @media(max-width:480px){

            .card{
                padding:28px 20px;
            }

            .logo{
                font-size:30px;
            }

        }

    </style>
</head>

<body>

<div class="container">

    <div class="card">

        <div class="logo">
            SKILLINK
        </div>

        <div class="subtitle">
            Buat password baru untuk akun kamu
        </div>

        <form method="POST" action="{{ url('/reset-password') }}">
            @csrf

            <input type="hidden" name="token" value="{{ $token }}">

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
            © SKILLINK
        </div>

    </div>

</div>

</body>
</html>
