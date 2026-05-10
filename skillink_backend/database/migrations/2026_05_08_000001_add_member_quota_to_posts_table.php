<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Tambah kolom max_anggota dan accepted_count ke tabel posts.
     */
    public function up(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            // Maksimal anggota yang mau direkrut (0 = tidak dibatasi / fitur lama)
            $table->unsignedInteger('max_anggota')->default(0)->after('is_boosted');
            // Jumlah lamaran yang sudah di-accept
            $table->unsignedInteger('accepted_count')->default(0)->after('max_anggota');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            $table->dropColumn(['max_anggota', 'accepted_count']);
        });
    }
};
