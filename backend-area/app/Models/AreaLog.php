<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AreaLog extends Model
{
    protected $fillable = ['area_id', 'status', 'message'];

    public function area()
    {
        return $this->belongsTo(Area::class);
    }
}
