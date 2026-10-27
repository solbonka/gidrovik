<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Characteristic;
use App\Models\Manufacturer;
use App\Models\Product;
use App\Services\ImageService;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class CatalogController extends Controller
{
    public function index(Request $request): Response
    {
        $query = Product::query()
            ->where('is_active', true)
            ->where('published', true)
            ->with(['category', 'manufacturer']);

        // Filter by category
        $categoryId = $request->input('category');
        if ($categoryId) {
            // Could be slug or ID
            $categoryModel = Category::where('slug', $categoryId)->first();
            if ($categoryModel) {
                $query->where('category_id', $categoryModel->id);
            }
        }

        // Filter by manufacturer
        $manufacturerId = $request->input('manufacturer');
        if ($manufacturerId) {
            $query->where('manufacturer_id', $manufacturerId);
        }

        // Filter by characteristics
        $characteristics = $request->input('characteristics', []);
        if (is_array($characteristics)) {
            foreach ($characteristics as $charId => $value) {
                if ($value !== '' && $value !== null) {
                    $query->whereHas('characteristicValues', function ($q) use ($charId, $value) {
                        $q->where('characteristic_id', $charId)
                            ->where('value', (string) $value);
                    });
                }
            }
        }

        // Sort
        $sort = $request->input('sort', 'created_at');
        $direction = $request->input('direction', 'desc');

        match ($sort) {
            'name' => $query->orderBy('name', $direction),
            'price' => $query->orderBy('retail_price', $direction),
            'created_at' => $query->orderBy('created_at', $direction),
            default => $query->orderBy('created_at', 'desc'),
        };

        $imageService = app(ImageService::class);

        $products = $query->paginate(24)->through(function (Product $product) use ($imageService) {
            return [
                'id' => $product->id,
                'name' => $product->name,
                'slug' => $product->slug,
                'sku' => $product->sku,
                'price' => $product->retail_price ?? '0',
                'image_path' => $product->images->first() ? $imageService->url($product->images->first()->image_path, 'thumbnail') : null,
                'stock_status' => $product->stock_status,
                'category' => $product->category?->name,
            ];
        });

        // Available filters
        $categories = Category::where('is_active', true)
            ->whereHas('products', fn ($q) => $q->where('is_active', true)->where('published', true))
            ->orderBy('name')
            ->get(['id', 'name', 'slug']);

        $manufacturers = Manufacturer::where('is_active', true)
            ->whereHas('products', fn ($q) => $q->where('is_active', true)->where('published', true))
            ->orderBy('name')
            ->get(['id', 'name']);

        // Get characteristics for current category
        $characteristics = collect();
        if ($categoryId) {
            $categoryModel = Category::where('slug', $categoryId)->first();
            if ($categoryModel) {
                $characteristics = $categoryModel->characteristics()
                    ->orderBy('category_characteristic.sort_order')
                    ->orderBy('characteristics.name')
                    ->get(['id', 'name', 'slug', 'type', 'unit']);
            }
        }

        // Get distinct values for selected characteristics
        $charValues = [];
        if ($characteristics->isNotEmpty()) {
            $charIds = $characteristics->pluck('id')->toArray();
            $categoryModel = $categoryId ? Category::where('slug', $categoryId)->first() : null;
            $values = \App\Models\ProductCharacteristicValue::query()
                ->whereIn('characteristic_id', $charIds)
                ->join('products', 'product_characteristic_values.product_id', '=', 'products.id')
                ->where('products.is_active', true)
                ->where('products.published', true)
                ->when($categoryModel, fn ($q) => $q->where('products.category_id', $categoryModel->id))
                ->select('characteristic_id', 'value')
                ->distinct()
                ->orderBy('value')
                ->get();

            $charValues = $values->groupBy('characteristic_id')
                ->map(fn ($items) => $items->pluck('value')->values());
        }

        return Inertia::render('store/catalog/Index', [
            'products' => $products,
            'categories' => $categories,
            'manufacturers' => $manufacturers,
            'characteristics' => $characteristics,
            'characteristic_values' => $charValues,
            'filters' => [
                'category' => $categoryId,
                'manufacturer' => $manufacturerId,
                'characteristics' => $characteristics,
                'sort' => $sort,
                'direction' => $direction,
            ],
        ])->with([
            'title' => 'Каталог товаров — Гидровик',
            'description' => 'Промышленное гидравлическое оборудование, фитинги, трубы и комплектующие. Поиск по категориям, производителям и техническим характеристикам.',
            'type' => 'website',
            'url' => url()->current(),
            'canonical' => url()->current(),
        ]);
    }
}
