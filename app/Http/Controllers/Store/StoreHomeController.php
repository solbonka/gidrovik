<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Services\ImageService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class StoreHomeController extends Controller
{
    public function __invoke(Request $request): Response
    {
        $categories = Category::query()
            ->where('is_active', true)
            ->withCount(['products' => fn ($q) => $q->where('is_active', true)])
            ->orderBy('name')
            ->limit(8)
            ->get()
            ->map(fn (Category $category): array => [
                'id' => $category->id,
                'name' => $category->name,
                'slug' => $category->slug,
                'product_count' => $category->products_count,
            ]);

        $imageService = app(ImageService::class);

        $featuredProducts = Product::query()
            ->where('is_active', true)
            ->addSelect([
                'min_stock' => DB::table('product_location')
                    ->selectRaw('COALESCE(SUM(quantity), 0)')
                    ->whereColumn('product_location.product_id', 'products.id'),
            ])
            ->orderByDesc('min_stock')
            ->limit(8)
            ->get()
            ->map(fn (Product $product) => [
                'id' => $product->id,
                'name' => $product->name,
                'slug' => $product->slug,
                'sku' => $product->sku,
                'price' => $product->retail_price ?? '0',
                'image_path' => $product->images->first() ? $imageService->url($product->images->first()->image_path, 'thumbnail') : null,
                'stock_status' => $this->resolveStockStatus($product),
            ]);

        $advantages = [
            [
                'icon' => 'shield',
                'title' => 'Гарантия качества',
                'description' => 'Вся продукция сертифицирована и проходит контроль качества перед отгрузкой.',
            ],
            [
                'icon' => 'truck',
                'title' => 'Быстрая доставка',
                'description' => 'Отправляем заказы в течение 1-2 рабочих дней по всей России.',
            ],
            [
                'icon' => 'support',
                'title' => 'Техническая поддержка',
                'description' => 'Поможем подобрать оборудование и ответим на ваши вопросы.',
            ],
        ];

        return Inertia::render('store/Home', [
            'categories' => $categories,
            'featuredProducts' => $featuredProducts,
            'advantages' => $advantages,
        ], 200, [
            'X-Store-Active' => 'true',
        ])->with([
            'title' => 'Гидровик — промышленное гидравлическое оборудование',
            'description' => 'Комплектующие, фитинги, трубы и сопутствующие товары от ведущих производителей. Розничные цены, доставка по всей России.',
            'image' => url('/og-home.png'),
            'type' => 'website',
            'url' => url('/'),
            'canonical' => url('/'),
        ]);
    }

    private function resolveStockStatus(Product $product): string
    {
        $total = (int) $product->total_quantity;

        if ($total > 0) {
            return 'in_stock';
        }

        // Allow backorder if product has some configuration
        // For now, default to backorder when out of stock
        return 'backorder';
    }
}
