<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\DB;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'product_type_id',
        'name',
        'sku',
        'minimum_stock',
        'angle',
        'description',
        'is_active',
        'unit',
        'manufacturer_id',
        'country_id',
    ];

    protected $casts = [
        'angle' => 'integer',
        'is_active' => 'boolean',
        'minimum_stock' => 'decimal:3',
        'unit' => 'string',
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

    public function getTotalQuantityAttribute(): string
    {
        $quantity = DB::table('product_location')
            ->where('product_id', $this->getKey())
            ->sum('quantity');

        return (string) ($quantity ?? '0');
    }

    public function manufacturer(): BelongsTo
    {
        return $this->belongsTo(Manufacturer::class);
    }

    public function country(): BelongsTo
    {
        return $this->belongsTo(Country::class);
    }
}
