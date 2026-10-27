<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function productTypes(): HasMany
    {
        return $this->hasMany(ProductType::class);
    }

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    public function characteristics(): BelongsToMany
    {
        return $this->belongsToMany(
            Characteristic::class,
            'category_characteristic'
        )
            ->select('characteristics.*')
            ->withPivot([
                'is_required',
                'sort_order',
            ])
            ->withTimestamps()
            ->orderByPivot('sort_order');
    }
}
