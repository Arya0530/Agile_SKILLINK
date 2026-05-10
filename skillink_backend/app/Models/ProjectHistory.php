<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProjectHistory extends Model
{
    protected $guarded = [];

    // Relasi: history ini milik siapa?
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi: history ini dari postingan mana?
    public function post()
    {
        return $this->belongsTo(Post::class);
    }
}
