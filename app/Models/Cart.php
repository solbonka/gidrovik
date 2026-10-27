<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Cart extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'session_id',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(CartItem::class);
    }

    public function getItemCountAttribute(): int
    {
        return $this->items->sum('quantity');
    }

    /**
     * Get or create a cart for a user.
     */
    public static function forUser(?User $user): self
    {
        if ($user) {
            return static::firstOrCreate(
                ['user_id' => $user->id],
                ['session_id' => null]
            );
        }

        $sessionId = session()->getId() ?? str()->random(40);
        if (!session()->getId()) {
            session(['cart_session_id' => $sessionId]);
        }

        return static::firstOrCreate(
            ['session_id' => $sessionId],
            []
        );
    }

    /**
     * Merge guest cart into user cart.
     */
    public function mergeInto(self $userCart): void
    {
        foreach ($this->items as $item) {
            $existing = $userCart->items()
                ->where('product_id', $item->product_id)
                ->first();

            if ($existing) {
                $existing->quantity = bcadd(
                    (string) $existing->quantity,
                    (string) $item->quantity,
                    3
                );
                $existing->save();
            } else {
                $userCart->items()->create([
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                ]);
            }
        }

        // Clear the guest cart
        $this->items()->delete();
    }
}
