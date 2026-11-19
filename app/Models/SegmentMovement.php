<?php

namespace App\Models;

use App\Enums\SegmentMovementType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SegmentMovement extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_segment_id',
        'product_id',
        'type',
        'from_location_id',
        'to_location_id',
        'length_mm',
        'stock_movement_id',
        'order_item_id',
        'comment',
        'user_id',
    ];

    protected $casts = [
        'length_mm' => 'decimal:3',
        'type' => SegmentMovementType::class,
    ];

    public function segment(): BelongsTo
    {
        return $this->belongsTo(ProductSegment::class, 'product_segment_id');
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function fromLocation(): BelongsTo
    {
        return $this->belongsTo(Location::class, 'from_location_id');
    }

    public function toLocation(): BelongsTo
    {
        return $this->belongsTo(Location::class, 'to_location_id');
    }

    public function stockMovement(): BelongsTo
    {
        return $this->belongsTo(StockMovement::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function orderItem(): BelongsTo
    {
        return $this->belongsTo(OrderItem::class);
    }
}
