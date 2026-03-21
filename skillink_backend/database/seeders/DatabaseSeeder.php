<?php

namespace Database\Seeders;

use App\Models\Post; // Tali penghubung ke tabel Post
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Postingan Lomba (Thoni)
        Post::create([
            'author_name' => 'Thoni',
            'author_major' => 'Product Owner | Mahasiswa TI',
            'post_type' => 'Lomba',
            'content' => 'URGENT! Sisa 2 hari lagi penutupan proposal Startup Kampus. Kita butuh banget anak MMB yang jago bikin Video Pitching dan Pitch Deck. Konsep udah mateng.',
            'tags' => '#VideoEditing #PitchDeck #Startup',
            'is_apply' => true,
            'is_boosted' => true,
        ]);

        // 2. Postingan Jasa (Budi)
        Post::create([
            'author_name' => 'Budi Santoso',
            'author_major' => 'Desainer Grafis | Mahasiswa MMB',
            'post_type' => 'Open Commission',
            'content' => 'Lagi buka jasa UI/UX Design buat aplikasi Tugas Akhir anak TI nih. Harga bersahabat ala kantong mahasiswa, revisi sampai deal. Boleh cek portfolio behance gw di profil.',
            'tags' => '#UIUX #Figma #Freelance',
            'is_apply' => false,
            'is_boosted' => false,
        ]);

        // 3. Postingan Kolaborasi (Lu Sendiri)
        Post::create([
            'author_name' => 'Arya Nugraha',
            'author_major' => 'Backend Developer | Mahasiswa D3 TI',
            'post_type' => 'Kolaborasi Proyek',
            'content' => 'Lagi iseng bikin aplikasi e-commerce rental mobil pakai Flutter & Laravel. Ada yang mau join buat ngerjain Frontend mobile-nya bareng? Hitung-hitung nambah portfolio di Github.',
            'tags' => '#Flutter #Laravel #SideProject',
            'is_apply' => true,
            'is_boosted' => false,
        ]);
    }
}