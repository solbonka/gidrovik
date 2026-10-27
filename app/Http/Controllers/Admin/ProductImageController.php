<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductImage;
use App\Services\ImageService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
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
                'images' => $product->images->map(fn ($image) => [
                    'id' => $image->id,
                    'path' => $image->url,
                    'alt' => $image->alt,
                    'display_order' => $image->display_order,
                ]),
            ],
        ]);
    }

    public function store(Request $request, Product $product): JsonResponse
    {
        $request->validate([
            'images' => 'required|array|min:1',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120', // max 5MB
            'alt' => 'nullable|array',
            'alt.*' => 'string|max:255',
        ]);

        $uploaded = [];

        foreach ($request->file('images') as $index => $file) {
            $originalName = pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME);
            $filename = $product->id . '_' . Str::slug($originalName) . '_' . Str::random(8) . '.webp';
            $path = 'products/' . $filename;

            // Store original
            $file->storeAs('products', $filename, 'public');

            // Generate optimized sizes
            $this->imageService->store($path);

            $image = ProductImage::create([
                'product_id' => $product->id,
                'image_path' => $path,
                'alt' => $request->input('alt.' . $index) ?? null,
                'display_order' => $index,
            ]);

            $uploaded[] = [
                'id' => $image->id,
                'path' => $image->url,
                'alt' => $image->alt,
                'display_order' => $image->display_order,
            ];
        }

        return response()->json([
            'success' => true,
            'images' => $uploaded,
        ]);
    }

    public function update(Request $request, Product $product, int $imageId): JsonResponse
    {
        $request->validate([
            'alt' => 'nullable|string|max:255',
            'display_order' => 'nullable|integer|min:0',
        ]);

        $image = $product->images()->findOrFail($imageId);

        $image->update([
            'alt' => $request->input('alt', $image->alt),
            'display_order' => $request->input('display_order', $image->display_order),
        ]);

        return response()->json([
            'success' => true,
            'image' => [
                'id' => $image->id,
                'path' => $image->url,
                'alt' => $image->alt,
                'display_order' => $image->display_order,
            ],
        ]);
    }

    public function reorder(Request $request, Product $product): JsonResponse
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

        return response()->json(['success' => true]);
    }

    public function destroy(Product $product, int $imageId): RedirectResponse
    {
        $image = $product->images()->findOrFail($imageId);
        $image->delete();

        // Delete all sizes from storage
        $this->imageService->delete($image->image_path);

        return back()->with('success', 'Изображение удалено.');
    }
}
