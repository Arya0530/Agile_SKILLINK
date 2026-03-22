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
        Schema::create('applications', function (Blueprint $table) {
            $table->id();
            // ID orang yang ngelamar (Arya)
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            // ID postingan kerjaan yang dilamar (Kelereng)
            $table->foreignId('post_id')->constrained()->onDelete('cascade');
            // Status lamaran: pending, accepted, rejected
            $table->string('status')->default('pending'); 
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('applications');
    }
};
