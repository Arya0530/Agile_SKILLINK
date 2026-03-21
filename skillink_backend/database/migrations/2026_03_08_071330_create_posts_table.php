<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
   {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->string('author_name');      // Nama (Contoh: Thoni)
            $table->string('author_major');     // Jurusan (Contoh: Product Owner | TI)
            $table->string('post_type');        // Tipe (Contoh: Lomba, Open Commission)
            $table->text('content');            // Isi postingan
            $table->string('tags');             // Tag (Contoh: #UIUX #Flutter)
            $table->boolean('is_apply')->default(true);    // Punya tombol Easy Apply atau nggak
            $table->boolean('is_boosted')->default(false); // Postingan premium (Warna Kuning) atau biasa
            $table->timestamps();
        });
    }
};
