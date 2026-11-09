<?php

namespace App\Services;

use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Drivers\Gd\Driver;
use Intervention\Image\Encoders\JpegEncoder;
use Intervention\Image\Encoders\WebpEncoder;
use Intervention\Image\ImageManager;
use Intervention\Image\Interfaces\EncoderInterface;

class ImageService
{
    public const CANONICAL_SIZE = 1200;

    protected ImageManager $manager;

    protected array $sizes;

    public function __construct()
    {
        $this->manager = new ImageManager(Driver::class);

        $this->sizes = [
            'thumbnail' => ['width' => 200, 'height' => 200, 'quality' => 80],
            'medium' => ['width' => 600, 'height' => 600, 'quality' => 85],
        ];
    }

    public function outputExtension(): string
    {
        return function_exists('imagewebp') ? 'webp' : 'jpg';
    }

    protected function encoder(int $quality): EncoderInterface
    {
        return function_exists('imagewebp')
            ? new WebpEncoder(quality: $quality)
            : new JpegEncoder(quality: $quality);
    }

    protected function disk(): Filesystem
    {
        return Storage::disk('public');
    }

    /**
     * Store uploaded source, apply crop, save 1200x1200 canonical image and derivatives.
     *
     * @param  array{x?:int|float,y?:int|float,width?:int|float,height?:int|float}|null  $crop
     * @return array{source_path:string,image_path:string,crop:?array}
     */
    public function storeCropped(UploadedFile $file, string $basePath, ?array $crop = null): array
    {
        $ext = $this->outputExtension();
        $sourcePath = $basePath.'_source.'.$ext;
        $imagePath = $basePath.'.'.$ext;

        $sourceBinary = (string) $this->manager->decodePath($file->getRealPath())
            ->encode($this->encoder(92));
        $this->disk()->put($sourcePath, $sourceBinary);

        $normalizedCrop = $this->renderCanonical($sourceBinary, $imagePath, $crop);
        $this->generateSizes($imagePath);

        return [
            'source_path' => $sourcePath,
            'image_path' => $imagePath,
            'crop' => $normalizedCrop,
        ];
    }

    /**
     * Re-render an existing image from its stored source using new crop data.
     *
     * @param  array{x?:int|float,y?:int|float,width?:int|float,height?:int|float}|null  $crop
     */
    public function recrop(string $sourcePath, string $imagePath, ?array $crop = null): ?array
    {
        $sourceBinary = (string) $this->disk()->get($sourcePath);
        $normalizedCrop = $this->renderCanonical($sourceBinary, $imagePath, $crop);
        $this->generateSizes($imagePath);

        return $normalizedCrop;
    }

    /**
     * Backward-compatible upload path used by older callers.
     */
    public function storeUploaded(UploadedFile $file, string $path, string $alt = ''): array
    {
        $binary = (string) $this->manager->decodePath($file->getRealPath())
            ->encode($this->encoder(90));
        $this->disk()->put($path, $binary);
        $this->generateSizes($path);

        return [];
    }

    /**
     * Store an image with optimized sizes.
     */
    public function store(string $path, string $alt = ''): array
    {
        $this->generateSizes($path);

        return [];
    }

    protected function renderCanonical(string $binary, string $imagePath, ?array $crop): ?array
    {
        $image = $this->manager->decodeBinary($binary);

        if (is_array($crop) && isset($crop['x'], $crop['y'], $crop['width'], $crop['height'])) {
            $x = max(0, (int) round((float) $crop['x']));
            $y = max(0, (int) round((float) $crop['y']));
            $width = max(1, (int) round((float) $crop['width']));
            $height = max(1, (int) round((float) $crop['height']));

            $maxWidth = max(1, $image->width() - $x);
            $maxHeight = max(1, $image->height() - $y);
            $width = min($width, $maxWidth);
            $height = min($height, $maxHeight);
            $size = max(1, min($width, $height));
            $image = $image->crop($size, $size, $x, $y);
            $normalizedCrop = ['x' => $x, 'y' => $y, 'width' => $size, 'height' => $size];
        } else {
            $side = min($image->width(), $image->height());
            $x = (int) floor(($image->width() - $side) / 2);
            $y = (int) floor(($image->height() - $side) / 2);
            $image = $image->crop($side, $side, $x, $y);
            $normalizedCrop = ['x' => $x, 'y' => $y, 'width' => $side, 'height' => $side];
        }

        $canonical = $image->cover(self::CANONICAL_SIZE, self::CANONICAL_SIZE)
            ->encode($this->encoder(90));
        $this->disk()->put($imagePath, (string) $canonical);

        return $normalizedCrop;
    }

    protected function generateSizes(string $imagePath): void
    {
        $binary = (string) $this->disk()->get($imagePath);
        $ext = $this->outputExtension();

        foreach ($this->sizes as $size => $config) {
            $encoded = $this->manager->decodeBinary($binary)
                ->cover($config['width'], $config['height'])
                ->encode($this->encoder($config['quality']));

            $thumbPath = $this->basePath($imagePath)."_{$size}.{$ext}";
            $this->disk()->put($thumbPath, (string) $encoded);
        }
    }

    /**
     * Delete an image and all its sizes.
     */
    public function delete(?string $path, ?string $sourcePath = null): void
    {
        $paths = [];
        foreach (array_filter([$path, $sourcePath]) as $target) {
            $paths[] = $target;
            $base = $this->basePath($target);
            foreach (['thumbnail', 'medium', 'large'] as $size) {
                foreach (['webp', 'jpg', 'jpeg', 'png'] as $ext) {
                    $paths[] = "{$base}_{$size}.{$ext}";
                }
            }
        }

        $this->disk()->delete(array_values(array_unique($paths)));
    }

    /**
     * Get the URL for a specific size.
     */
    public function url(string $path, string $size = 'medium'): string
    {
        if ($size === 'large') {
            return $this->disk()->url($path);
        }

        $base = $this->basePath($path);

        foreach (['webp', 'jpg', 'jpeg', 'png'] as $ext) {
            $thumbPath = "{$base}_{$size}.{$ext}";
            if ($this->disk()->exists($thumbPath)) {
                return $this->disk()->url($thumbPath);
            }
        }

        return $this->disk()->url($path);
    }

    /**
     * Generate missing thumbnails for existing images.
     */
    public function regenerateMissing(string $path): void
    {
        $base = $this->basePath($path);
        $ext = $this->outputExtension();
        foreach ($this->sizes as $size => $config) {
            $thumbPath = "{$base}_{$size}.{$ext}";
            if (! $this->disk()->exists($thumbPath)) {
                try {
                    $this->generateSizes($path);
                } catch (\Throwable $e) {
                    // Skip if original is missing or corrupted
                }
                break;
            }
        }
    }

    protected function basePath(string $path): string
    {
        return preg_replace('/_(source|thumbnail|medium|large)$|\.(webp|jpe?g|png)$/i', '', $path) ?? $path;
    }
}
