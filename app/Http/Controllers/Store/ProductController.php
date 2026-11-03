<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Product;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ProductController extends Controller
{
    public function __invoke(Request $request, Product $product): Response
    {
        // Only show published products
        abort_unless($product->is_active && $product->published, 404);

        $product->load(['characteristicValues.characteristic', 'images']);

        $imageService = app(\App\Services\ImageService::class);

        $productData = [
            'id' => $product->id,
            'name' => $product->name,
            'slug' => $product->slug,
            'code' => $product->code,
            'article' => $product->article,
            'description' => $product->description,
            'price' => $product->retail_price ?? '0',
            'stock_status' => $product->stock_status,
            'manufacturer' => $product->manufacturer?->name,
            'category' => $product->category?->name,
            'meta_title' => $product->meta_title ?? $product->name,
            'meta_description' => $product->meta_description ?? $product->description,
            'images' => $product->images->map(fn ($image) => [
                'id' => $image->id,
                'path' => $imageService->url($image->image_path, 'medium'),
                'large' => $imageService->url($image->image_path, 'large'),
                'alt' => $image->alt,
            ]),
            'characteristics' => $product->characteristicValues->map(fn ($cv) => [
                'id' => $cv->characteristic->id,
                'name' => $cv->characteristic->name,
                'value' => $cv->value,
                'unit' => $cv->characteristic->unit,
            ]),
        ];

        // Related products (same category)
        $relatedProducts = Product::query()
            ->where('is_active', true)
            ->where('published', true)
            ->where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->limit(8)
            ->get()
            ->map(fn (Product $p) => [
                'id' => $p->id,
                'name' => $p->name,
                'slug' => $p->slug,
                'price' => $p->retail_price ?? '0',
                'image_path' => $p->images->first() ? $imageService->url($p->images->first()->image_path, 'thumbnail') : null,
                'stock_status' => $p->stock_status,
            ]);

        // Get favorite product IDs for authenticated user
        $favoriteProductIds = [];
        if (auth()->check()) {
            $favoriteProductIds = Favorite::where('user_id', auth()->id())
                ->pluck('product_id')
                ->toArray();
        }

        return Inertia::render('store/products/Show', [
            'product' => $productData,
            'related_products' => $relatedProducts,
            'favorite_product_ids' => $favoriteProductIds,
        ])->with([
            'title' => $product->meta_title,
            'description' => $product->meta_description,
            'image' => $product->images->first() ? $imageService->url($product->images->first()->image_path, 'large') : url('/og-product.png'),
            'type' => 'product',
            'url' => url()->current(),
            'canonical' => url()->current(),
        ]);
    }
}
