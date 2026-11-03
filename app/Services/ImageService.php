<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class ImageService
{
    protected ImageManager $manager;

    protected array $sizes;

    public function __construct()
    {
        $this->manager = new ImageManager(Driver::class);

        $this->sizes = [
            'thumbnail' => ['width' => 200, 'height' => 200, 'quality' => 80],
            'medium' => ['width' => 600, 'height' => 600, 'quality' => 85],
            'large' => ['width' => 1200, 'height' => 1200, 'quality' => 90],
        ];
    }

    /**
     * Store an image with optimized sizes.
     */
    public function store(string $path, string $alt = ''): array
    {
        $image = $this->manager->decodeBinary(Storage::read($path));

        $results = [];

        foreach ($this->sizes as $size => $config) {
            $encoded = $image->clone()
                ->resize($config['width'], $config['height'], fn ($constraint) => $constraint->aspectRatio())
                ->cover($config['width'], $config['height'])
                ->encode('webp', $config['quality']);

            $thumbPath = str_replace('.webp', '', $path) . "_{$size}.webp";
            Storage::put($thumbPath, $encoded);

            $results[$size] = $thumbPath;
        }

        return $results;
    }

    /**
     * Delete an image and all its sizes.
     */
    public function delete(string $path): void
    {
        $base = str_replace('.webp', '', $path);

        Storage::delete([
            $path,
            $base . '_thumbnail.webp',
            $base . '_medium.webp',
            $base . '_large.webp',
        ]);
    }

    /**
     * Get the URL for a specific size.
     */
    public function url(string $path, string $size = 'medium'): string
    {
        $base = str_replace('.webp', '', $path);

        if (! Storage::exists($base . "_{$size}.webp")) {
            return Storage::url($path);
        }

        return Storage::url($base . "_{$size}.webp");
    }

    /**
     * Generate missing thumbnails for existing images.
     */
    public function regenerateMissing(string $path): void
    {
        $base = str_replace('.webp', '', $path);

        foreach ($this->sizes as $size => $config) {
            $thumbPath = $base . "_{$size}.webp";

            if (! Storage::exists($thumbPath)) {
                try {
                    $image = $this->manager->decodeBinary(Storage::read($path));
                    $encoded = $image->resize($config['width'], $config['height'], fn ($constraint) => $constraint->aspectRatio())
                        ->cover($config['width'], $config['height'])
                        ->encode('webp', $config['quality']);
                    Storage::put($thumbPath, $encoded);
                } catch (\Throwable $e) {
                    // Skip if original is missing or corrupted
                }
            }
        }
    }
}
