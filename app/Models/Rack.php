<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Rack extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'warehouse_id',
    ];

    public function warehouse(): BelongsTo
    {
        return $this->belongsTo(Warehouse::class);
    }

    public function locations(): HasMany
    {
        return $this->hasMany(Location::class);
    }
}
