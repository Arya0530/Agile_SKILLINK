<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Tambah kolom status rekrutmen & penyelesaian proyek ke tabel posts.
     *
     * is_closed   → owner klik "Tutup Rekrutmen" (manual close)
     *               Post hilang dari For You, muncul di My Post dengan label "Ditutup"
     *
     * is_completed → owner klik "Proyek Selesai"
     *               Post hilang dari For You, label berubah jadi "Proyek Selesai"
     *               History otomatis dibuat untuk semua anggota yang accepted
     *
     * completed_at → waktu proyek dinyatakan selesai (untuk periode portofolio)
     */
    public function up(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            // Ditutup manual oleh owner (beda dari is_apply=0 yg auto karena kuota penuh)
            $table->boolean('is_closed')->default(false)->after('is_apply');
            // Proyek sudah selesai
            $table->boolean('is_completed')->default(false)->after('is_closed');
            // Timestamp saat proyek dinyatakan selesai
            $table->timestamp('completed_at')->nullable()->after('is_completed');
        });
    }

    public function down(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            $table->dropColumn(['is_closed', 'is_completed', 'completed_at']);
        });
    }
};
