<?php

namespace App\Models;

use App\Enums\OrderStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'customer_name',
        'customer_email',
        'customer_phone',
        'customer_organization',
        'delivery_method',
        'delivery_address',
        'comment',
        'total_amount',
        'status',
        'user_id',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'status' => OrderStatus::class,
    ];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function (Order $order) {
            if (empty($order->order_number)) {
                $order->order_number = self::generateOrderNumber();
            }
        });
    }

    public static function generateOrderNumber(): string
    {
        $year = date('Y');
        $lastOrder = self::whereYear('created_at', $year)
            ->orderByDesc('id')
            ->first();

        $nextNumber = $lastOrder ? (int) substr($lastOrder->order_number, -5) + 1 : 1;

        return sprintf('ORD-%s-%05d', $year, $nextNumber);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(OrderStatusHistory::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function getRouteKeyName(): string
    {
        return 'order_number';
    }
}
