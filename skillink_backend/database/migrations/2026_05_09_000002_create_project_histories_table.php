<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tabel project_histories — portofolio otomatis dari proyek yang selesai.
     *
     * Setiap kali owner klik "Proyek Selesai", satu record dibuat untuk:
     *   - Owner post itu sendiri
     *   - Semua pelamar yang statusnya 'accepted'
     *
     * Data yang disimpan sesuai kebutuhan portofolio:
     *   - project_title  → isi konten post (max 200 char)
     *   - leader_name    → author_name dari post (nama/username pemosting)
     *   - start_date     → created_at dari post (tanggal postingan dibuat)
     *   - end_date       → completed_at dari post (tanggal proyek berakhir)
     */
    public function up(): void
    {
        Schema::create('project_histories', function (Blueprint $table) {
            $table->id();

            // Pemilik record ini (anggota proyek)
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            // Referensi ke post asal (biar bisa link ke detail kalau diperlukan)
            $table->foreignId('post_id')->constrained()->cascadeOnDelete();

            // Data portofolio yang di-snapshot saat proyek selesai
            $table->string('project_title', 200);
            $table->string('leader_name');   // author_name dari post (username ketua)
            $table->date('start_date');      // tanggal post dibuat
            $table->date('end_date');        // tanggal proyek dinyatakan selesai

            $table->timestamps();

            // Satu user tidak bisa punya 2 record history untuk post yang sama
            $table->unique(['user_id', 'post_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('project_histories');
    }
};
