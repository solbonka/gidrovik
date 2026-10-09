<?php

namespace App\Models;

use App\Enums\StockMovementType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StockMovement extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'from_location_id',
        'to_location_id',
        'quantity',
        'type',
        'comment',
        'user_id',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'type' => StockMovementType::class,
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function fromLocation(): BelongsTo
    {
        return $this->belongsTo(
            Location::class,
            'from_location_id'
        );
    }

    public function toLocation(): BelongsTo
    {
        return $this->belongsTo(
            Location::class,
            'to_location_id'
        );
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
