<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Skill extends Model
{
    use HasFactory;

    // Kolom yang boleh diisi
    protected $fillable = ['user_id', 'name'];

    // Relasi balik ke User (Skill ini milik siapa)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}