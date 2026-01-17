<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $fillable = ['name', 'icon', 'description', 'is_active'];
    
    // Relation : Un service peut être lié à plusieurs utilisateurs
    public function userServices()
    {
        return $this->hasMany(UserService::class);
    }
}
