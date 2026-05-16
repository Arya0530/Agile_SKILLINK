<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Normalize "Multi media" → "D3 Teknologi Multimedia Broadcasting (MMB)"
        DB::table('users')
            ->where('jurusan', 'Multi media')
            ->update(['jurusan' => 'D3 Teknologi Multimedia Broadcasting (MMB)']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Rollback
        DB::table('users')
            ->where('jurusan', 'D3 Teknologi Multimedia Broadcasting (MMB)')
            ->update(['jurusan' => 'Multi media']);
    }
};
