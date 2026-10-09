<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Diameter extends Model
{
    use HasFactory;

    protected $fillable = [
        'value',
        'unit',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'value' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function connections(): HasMany
    {
        return $this->hasMany(ProductConnection::class);
    }
}
