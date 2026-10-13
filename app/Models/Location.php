<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Location extends Model
{
    use HasFactory;

    protected $fillable = [
        'rack_id',
        'number',
    ];

    protected $appends = [
        'code',
    ];

    protected function code(): Attribute
    {
        return Attribute::get(
            fn (): string => "{$this->rack->code}-{$this->number}",
        );
    }

    public function rack(): BelongsTo
    {
        return $this->belongsTo(Rack::class);
    }

    public function products(): BelongsToMany
    {
        return $this->belongsToMany(
            Product::class,
            'product_location',
        )->withPivot('quantity')->withTimestamps();
    }

    public function incomingMovements(): HasMany
    {
        return $this->hasMany(
            StockMovement::class,
            'to_location_id',
        );
    }

    public function outgoingMovements(): HasMany
    {
        return $this->hasMany(
            StockMovement::class,
            'from_location_id',
        );
    }
}
