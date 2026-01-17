<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // Important pour les tokens

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable; // Ajoute HasApiTokens ici

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'google_id',
        'google_token',
        'google_refresh_token',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'google_token',         // Sécurité : on cache les tokens quand on renvoie l'objet User
        'google_refresh_token', // Sécurité
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

    // Relation : Un utilisateur a plusieurs comptes liés (Google, Discord...)
    public function connectedServices()
    {
        return $this->hasMany(UserService::class);
    }

    // Relation many-to-many : Un utilisateur a plusieurs services avec pivot data
    public function services()
    {
        return $this->belongsToMany(Service::class, 'user_services')
            ->withPivot('access_token', 'refresh_token', 'expires_at')
            ->withTimestamps();
    }

    // Relation : Un utilisateur a plusieurs automatisations (AREAs)
    public function areas()
    {
        return $this->hasMany(Area::class);
    }
}
