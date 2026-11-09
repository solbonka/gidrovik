<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductImage;
use App\Services\ImageService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class ProductImageController extends Controller
{
    public function __construct(
        protected ImageService $imageService
    ) {}

    public function index(Product $product): Response
    {
        $product->load('images');

        return Inertia::render('admin/products/Images', [
            'product' => [
                'id' => $product->id,
                'name' => $product->name,
                'images' => $product->images->map(fn (ProductImage $image) => [
                    'id' => $image->id,
                    'path' => $image->url,
                    'source_path' => $image->source_path
                        ? Storage::disk('public')->url($image->source_path)
                        : null,
                    'alt' => $image->alt,
                    'display_order' => $image->display_order,
                    'crop' => $image->crop,
                    'canonical_size' => ImageService::CANONICAL_SIZE,
                ]),
            ],
        ]);
    }

    public function store(Request $request, Product $product): RedirectResponse
    {
        $validated = $request->validate([
            'image' => 'required_without:images|nullable|image|mimes:jpeg,png,jpg,webp|max:10240',
            'images' => 'required_without:image|nullable|array|min:1',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:10240',
            'alt' => 'nullable|array',
            'alt.*' => 'nullable|string|max:255',
            'crop' => 'nullable|array',
            'crop.x' => 'nullable|numeric|min:0',
            'crop.y' => 'nullable|numeric|min:0',
            'crop.width' => 'nullable|numeric|min:1',
            'crop.height' => 'nullable|numeric|min:1',
        ]);

        $files = [];
        if ($request->hasFile('image')) {
            $files[] = $request->file('image');
        }
        foreach ($request->file('images', []) as $file) {
            if ($file) {
                $files[] = $file;
            }
        }

        foreach (array_values($files) as $index => $file) {
            $originalName = pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME);
            $basePath = 'products/'.$product->id.'_'.Str::slug($originalName).'_'.Str::random(8);
            $crop = $index === 0 && $request->filled('crop') ? $validated['crop'] : null;
            $stored = $this->imageService->storeCropped($file, $basePath, $crop);

            ProductImage::create([
                'product_id' => $product->id,
                'image_path' => $stored['image_path'],
                'source_path' => $stored['source_path'],
                'alt' => $request->input('alt.'.$index) ?? null,
                'display_order' => $index,
                'crop' => $stored['crop'],
            ]);
        }

        return back()->with('success', 'Изображения загружены.');
    }

    public function update(Request $request, Product $product, int $imageId): RedirectResponse
    {
        $validated = $request->validate([
            'alt' => 'nullable|string|max:255',
            'display_order' => 'nullable|integer|min:0',
            'crop' => 'nullable|array',
            'crop.x' => 'required_with:crop|numeric|min:0',
            'crop.y' => 'required_with:crop|numeric|min:0',
            'crop.width' => 'required_with:crop|numeric|min:1',
            'crop.height' => 'required_with:crop|numeric|min:1',
        ]);

        $image = $product->images()->findOrFail($imageId);
        $payload = [];

        if ($request->has('alt')) {
            $payload['alt'] = $validated['alt'] ?? $image->alt;
        }
        if ($request->has('display_order')) {
            $payload['display_order'] = $validated['display_order'] ?? $image->display_order;
        }

        if ($request->filled('crop') && $image->source_path) {
            $payload['crop'] = $this->imageService->recrop(
                $image->source_path,
                $image->image_path,
                $validated['crop'],
            );
        }

        if ($payload !== []) {
            $image->update($payload);
        }

        return back()->with('success', 'Изображение обновлено.');
    }

    public function reorder(Request $request, Product $product): RedirectResponse
    {
        $request->validate([
            'order' => 'required|array',
            'order.*' => 'integer|exists:product_images,id',
        ]);

        foreach ($request->input('order') as $index => $imageId) {
            ProductImage::where('id', $imageId)
                ->where('product_id', $product->id)
                ->update(['display_order' => $index]);
        }

        return back()->with('success', 'Порядок изображений обновлен.');
    }

    public function destroy(Product $product, int $imageId): RedirectResponse
    {
        $image = $product->images()->findOrFail($imageId);
        $this->imageService->delete($image->image_path, $image->source_path);
        $image->delete();

        return back()->with('success', 'Изображение удалено.');
    }
}
