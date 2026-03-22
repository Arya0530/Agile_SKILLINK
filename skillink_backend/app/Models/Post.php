<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $guarded = [];

    // Relasi: Postingan ini yang bikin siapa (Penerima Lamaran)
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi: Postingan ini dilamar sama siapa aja
    public function applications()
    {
        return $this->hasMany(Application::class);
    }
}