<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // 👇 INI KEKUATAN BARUNYA 👇

class User extends Authenticatable
{
    // 👇 DAN HARUS DIPASANG DI SINI JUGA 👇
    use HasApiTokens, HasFactory, Notifiable; 

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
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
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
    // Relasi ke tabel skills (Satu user punya banyak skill)
    public function skills()
    {
        return $this->hasMany(Skill::class);
    }

    // Relasi ke tabel projects (Satu user punya banyak project)
    public function projects()
    {
        return $this->hasMany(Project::class);
    }
    // Relasi ke tabel applications (Satu user bisa ngelamar banyak kerjaan)
    public function applications()
    {
        return $this->hasMany(Application::class);
    }
    // Relasi ke tabel posts (Satu user bisa bikin banyak postingan)
    public function posts()
    {
        return $this->hasMany(Post::class);
    }
}