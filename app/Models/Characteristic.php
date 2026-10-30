<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\CharacteristicValue;

class Characteristic extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'type',
        'unit',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function categories(): BelongsToMany
    {
        return $this->belongsToMany(
            Category::class,
            'category_characteristic'
        )
            ->select('categories.*')
            ->withPivot([
                'is_required',
                'sort_order',
            ])
            ->withTimestamps()
            ->orderByPivot('sort_order');
    }

    public function productValues(): HasMany
    {
        return $this->hasMany(ProductCharacteristicValue::class);
    }

    public function values(): HasMany
    {
        return $this->hasMany(CharacteristicValue::class)
            ->orderBy('sort_order')
            ->orderBy('value');
    }
}
