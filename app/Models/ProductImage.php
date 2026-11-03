<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class ProductImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'image_path',
        'alt',
        'display_order',
    ];

    protected $casts = [
        'display_order' => 'integer',
    ];

    protected static function boot(): void
    {
        parent::boot();

        // Regenerate missing thumbnails on first load
        static::retrieved(function (ProductImage $image) {
            if (!$image->image_path) {
                return;
            }

            $base = str_replace('.webp', '', $image->image_path);
            $sizes = ['thumbnail', 'medium', 'large'];
            $anyMissing = false;

            foreach ($sizes as $size) {
                $thumbPath = $base . "_{$size}.webp";
                if (!Storage::exists($thumbPath)) {
                    $anyMissing = true;
                    break;
                }
            }

            if (!$anyMissing) {
                return;
            }

            try {
                $imageService = app(\App\Services\ImageService::class);
                $imageService->regenerateMissing($image->image_path);
            } catch (\Throwable $e) {
                // Skip if original is missing or corrupted
            }
        });
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }

    /**
     * Get the full URL for the image (medium size by default).
     */
    public function getUrlAttribute(): string
    {
        return app(\App\Services\ImageService::class)->url($this->image_path, 'medium');
    }

    /**
     * Get URL for a specific size.
     */
    public function getUrlForSize(string $size = 'medium'): string
    {
        return app(\App\Services\ImageService::class)->url($this->image_path, $size);
    }
}
