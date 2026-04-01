🚀 Panduan Setup Lokal Project SKILLINK

A. Setup Backend (Laravel)

    Buka folder backend di terminal/VS Code.

    Install mesin Laravelnya dengan ketik:
    composer install

    Copy file .env.example dan ubah namanya jadi .env. (Bisa ketik cp .env.example .env di terminal).

    Buka file .env yang baru dibuat, cari bagian database, lalu ubah jadi :
    
    DB_CONNECTION=mysql
    DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_DATABASE=db_skillink
    DB_USERNAME=root
    DB_PASSWORD=

    Buka XAMPP, nyalain Apache dan MySQL.

    Buka browser, masuk ke localhost/phpmyadmin, lalu bikin database baru dengan nama db_skillink.

    Generate kunci aplikasi dengan ketik:
    php artisan key:generate

    Bangun tabel databasenya dengan ketik:
    php artisan migrate

    Nyalain server lokalnya:
    php artisan serve

B. Setup Ngrok (Biar nyambung ke HP/Emulator)

    Buka terminal baru, nyalain Ngrok buat nge-hosting port 8000:
    ngrok http 8000

    Copy link HTTPS yang muncul (contoh: https://abcd.ngrok-free.dev).

C. Setup Frontend (Flutter)

    Buka folder frontend di VS Code.

    Tarik semua package Flutter dengan ketik:
    flutter pub get

    Buka file lib/api_config.dart.

    Ganti isi baseUrl dengan link Ngrok yang baru kalian dapet. Contoh:
    static const String baseUrl = 'https://abcd.ngrok-free.dev/api';

    Save file-nya, lalu Run aplikasinya contohnya di hp 