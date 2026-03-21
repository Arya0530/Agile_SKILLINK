<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    // Kolom yang boleh diisi
    protected $fillable = ['user_id', 'title', 'role', 'description'];

    // Relasi balik ke User (Project ini milik siapa)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}