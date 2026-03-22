<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Application extends Model
{
    protected $guarded = [];

    // Relasi: Lamaran ini dikirim sama siapa?
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi: Lamaran ini buat postingan yang mana?
    public function post()
    {
        return $this->belongsTo(Post::class);
    }
}