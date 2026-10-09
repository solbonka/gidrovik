<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'product_type_id',
        'name',
        'sku',
        'angle',
        'description',
        'is_active',
    ];

    protected $casts = [
        'angle' => 'integer',
        'is_active' => 'boolean',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function productType(): BelongsTo
    {
        return $this->belongsTo(ProductType::class);
    }

    public function characteristicValues(): HasMany
    {
        return $this->hasMany(ProductCharacteristicValue::class);
    }

    public function connections(): HasMany
    {
        return $this->hasMany(ProductConnection::class)
            ->orderBy('position');
    }

    public function locations(): BelongsToMany
    {
        return $this->belongsToMany(
            Location::class,
            'product_location'
        )
            ->using(ProductLocation::class)
            ->withPivot('quantity')
            ->withTimestamps();
    }

    public function stockMovements(): HasMany
    {
        return $this->hasMany(StockMovement::class);
    }

    public function getTotalQuantityAttribute(): int
    {
        return (int) $this->locations()
            ->sum('product_location.quantity');
    }
}
