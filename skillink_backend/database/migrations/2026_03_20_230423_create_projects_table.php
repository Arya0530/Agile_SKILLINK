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
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            // Sambungan ke ID user yang login
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); 
            // Judul proyek
            $table->string('title'); 
            // Peran lu di proyek (ex: Fullstack Developer)
            $table->string('role'); 
            // Deskripsi proyek
            $table->text('description'); 
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
