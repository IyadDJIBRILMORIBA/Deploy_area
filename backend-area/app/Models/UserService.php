<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserService extends Model
{
    protected $fillable = [
        'user_id',
        'service_id',
        'provider_id',
        'access_token',
        'refresh_token',
        'expires_at',
        'name'
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
