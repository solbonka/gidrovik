<?php

namespace App\Models;

use App\Enums\ProductSegmentStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ProductSegment extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'location_id',
        'parent_segment_id',
        'length_mm',
        'status',
        'stock_movement_id',
        'order_item_id',
    ];

    protected $casts = [
        'length_mm' => 'decimal:3',
        'status' => ProductSegmentStatus::class,
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    public function location(): BelongsTo
    {
        return $this->belongsTo(Location::class);
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(ProductSegment::class, 'parent_segment_id');
    }

    public function stockMovement(): BelongsTo
    {
        return $this->belongsTo(StockMovement::class);
    }

    public function movements(): HasMany
    {
        return $this->hasMany(SegmentMovement::class);
    }

    public function orderItem(): BelongsTo
    {
        return $this->belongsTo(OrderItem::class);
    }

    /**
     * Длина отрезка в единицах товара (метры для unit = 'м').
     */
    public function lengthInProductUnit(): string
    {
        return bcdiv((string) $this->length_mm, '1000', 3);
    }
}
