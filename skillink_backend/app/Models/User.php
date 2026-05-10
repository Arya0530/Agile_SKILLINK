<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'jurusan',
        'no_wa',
    ];

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
        ];
    }

    // ─── RELASI ───────────────────────────────────────────────────────────────

    // Postingan yang dibuat user ini
    public function posts()
    {
        return $this->hasMany(Post::class);
    }

    // Lamaran yang dikirim user ini
    public function applications()
    {
        return $this->hasMany(Application::class);
    }

    // Skill yang dimiliki user ini
    public function skills()
    {
        return $this->hasMany(Skill::class);
    }

    // Proyek manual yang ditambahkan user ini (entry manual)
    public function projects()
    {
        return $this->hasMany(Project::class);
    }

    // [BARU] Portofolio otomatis dari proyek yang selesai
    public function projectHistories()
    {
        return $this->hasMany(ProjectHistory::class)->latest();
    }
}
