<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Area extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'is_active',
        'trigger_service',
        'trigger_action',
        'trigger_params',
        'action_service',
        'action_reaction',
        'action_params'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'trigger_params' => 'array',
        'action_params' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function logs()
    {
        return $this->hasMany(AreaLog::class);
    }
}
