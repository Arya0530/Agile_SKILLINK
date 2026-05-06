# Add Save Login, Logout Confirmation, & Reset Password via Email

Fitur yang ditambahkan:
- Save Login menggunakan `SharedPreferences`
- Logout Confirmation Dialog
- Reset Password melalui Email
- Integrasi SMTP Gmail
- Support URL publik menggunakan Ngrok

---

# 1. Setup Mail Configuration (.env)

Buka file `.env` Laravel kalian, lalu ubah bagian `MAIL` menjadi berikut:

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=skillinkappadmin@gmail.com
MAIL_PASSWORD=jwwiodrdqdgvpipv
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=skillinkappadmin@gmail.com
MAIL_FROM_NAME="SKILLINK"
```

> Gunakan App Password Gmail, bukan password Gmail asli.

---

# 2. Setup APP_URL

Masih di file `.env`, ubah bagian:

```env
APP_URL=http://localhost:8000
```

menjadi URL publik dari Ngrok atau domain website kalian.

Contoh:

```env
APP_URL=https://unphrased-noninstinctively-julietta.ngrok-free.dev
```

> APP_URL digunakan untuk generate link reset password yang dikirim ke email user.

---