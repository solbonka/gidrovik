<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Characteristic;
use App\Models\Favorite;
use App\Models\Product;
use App\Models\ProductCharacteristicValue;
use App\Models\ProductType;
use App\Services\ImageService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
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

        // Search by name, code, article
        $search = trim((string) $request->input('search', ''));
        if ($search) {
            $words = preg_split('/\s+/u', mb_strtolower(trim($search), 'UTF-8'), -1, PREG_SPLIT_NO_EMPTY);
            if (! empty($words)) {
                $query->where(function ($q) use ($words) {
                    foreach ($words as $word) {
                        $word = addcslashes($word, '%_\\');
                        $q->where(function ($q) use ($word) {
                            $q->whereRaw('LOWER(name) LIKE ?', ["%{$word}%"])
                                ->orWhereRaw('LOWER(code) LIKE ?', ["%{$word}%"])
                                ->orWhereRaw('LOWER(article) LIKE ?', ["%{$word}%"]);
                        });
                    }
                });
            }
        }

        // Filter by category
        $categoryId = $request->input('category');
        $categoryModel = null;
        if ($categoryId) {
            // Could be slug or ID
            $categoryQuery = Category::query()->where('slug', $categoryId);

            if (is_numeric($categoryId)) {
                $categoryQuery->orWhere('id', (int) $categoryId);
            }

            $categoryModel = $categoryQuery->first();
            if ($categoryModel) {
                $query->where('category_id', $categoryModel->id);
            }
        }

        // Filter by price range
        $minPrice = $request->input('min_price');
        $maxPrice = $request->input('max_price');
        if ($minPrice !== null && $minPrice !== '') {
            $query->where('retail_price', '>=', (float) $minPrice);
        }
        if ($maxPrice !== null && $maxPrice !== '') {
            $query->where('retail_price', '<=', (float) $maxPrice);
        }

        // Filter by standard (connection type)
        $standardId = $request->input('standard');
        if ($standardId) {
            $query->whereHas('connections', function ($q) use ($standardId) {
                $q->where('standard_id', $standardId);
            });
        }

        // Filter by diameter
        $diameterId = $request->input('diameter');
        if ($diameterId) {
            $query->whereHas('connections', function ($q) use ($diameterId) {
                $q->where('diameter_id', $diameterId);
            });
        }

        // Filter by product type
        $productTypeId = $request->input('product_type');
        if ($productTypeId) {
            $query->where('product_type_id', $productTypeId);
        }

        // Filter by stock status
        $stockStatus = $request->input('stock_status');
        $stockStatus = in_array($stockStatus, ['in_stock', 'out_of_stock'], true) ? $stockStatus : null;
        if ($stockStatus) {
            match ($stockStatus) {
                'in_stock' => $query->whereHas('locations', fn ($q) => $q->where('quantity', '>', 0)),
                'out_of_stock' => $query->whereDoesntHave('locations', fn ($q) => $q->where('quantity', '>', 0)),
                default => null,
            };
        }

        // Filter by characteristics
        $selectedCharacteristics = $request->input('characteristics', []);
        $selectedCharacteristics = is_array($selectedCharacteristics) ? $selectedCharacteristics : [];
        $selectedCharacteristics = collect($selectedCharacteristics)
            ->filter(fn ($value, $key) => is_numeric($key) && is_scalar($value) && $value !== '')
            ->all();

        if ($selectedCharacteristics !== []) {
            $booleanCharacteristicIds = Characteristic::query()
                ->whereIn('id', array_keys($selectedCharacteristics))
                ->where('type', 'boolean')
                ->pluck('id')
                ->map(fn ($id) => (string) $id)
                ->all();

            foreach ($selectedCharacteristics as $charId => $value) {
                $query->whereHas('characteristicValues', function ($q) use ($charId, $value, $booleanCharacteristicIds) {
                    $q->where('characteristic_id', $charId);

                    if (in_array((string) $charId, $booleanCharacteristicIds, true)) {
                        // В каталоге переключатель означает наличие признака (true).
                        $q->whereRaw("LOWER(TRIM(value)) IN ('1', 'true', 'yes', 'да', 'on')");
                    } else {
                        $q->where('value', (string) $value);
                    }
                });
            }
        }

        // Sort
        $sort = (string) $request->input('sort', 'created_at');
        $sort = in_array($sort, ['created_at', 'name', 'price'], true) ? $sort : 'created_at';

        $direction = strtolower((string) $request->input('direction', 'desc'));
        $direction = in_array($direction, ['asc', 'desc'], true) ? $direction : 'desc';

        $query->orderBy(
            match ($sort) {
                'name' => 'name',
                'price' => 'retail_price',
                default => 'created_at',
            },
            $direction,
        );

        $imageService = app(ImageService::class);

        $products = $query->paginate(24)->through(function (Product $product) use ($imageService) {
            return [
                'id' => $product->id,
                'name' => $product->name,
                'slug' => $product->slug,
                'code' => $product->code,
                'article' => $product->article,
                'price' => $product->retail_price ?? '0',
                'unit' => $product->unit ?? 'шт.',
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

        // Get characteristics for current category
        $characteristics = collect();
        if ($categoryModel) {
            $characteristics = $categoryModel->characteristics()
                ->orderBy('category_characteristic.sort_order')
                ->orderBy('characteristics.name')
                ->get(['id', 'name', 'slug', 'type', 'unit']);
        }

        // Get distinct values for selected characteristics
        $charValues = [];
        if ($characteristics->isNotEmpty()) {
            $charIds = $characteristics->pluck('id')->toArray();
            // $categoryModel уже найден выше по slug или числовому ID.
            $values = ProductCharacteristicValue::query()
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

        // Get favorite product IDs for authenticated user
        $favoriteProductIds = [];
        if (auth()->check()) {
            $favoriteProductIds = Favorite::where('user_id', auth()->id())
                ->pluck('product_id')
                ->toArray();
        }

        // Get available standards for current category
        $standards = collect();
        if ($categoryModel) {
            $standards = DB::table('standards')
                ->join('product_connections', 'standards.id', '=', 'product_connections.standard_id')
                ->join('products', 'product_connections.product_id', '=', 'products.id')
                ->where('products.category_id', $categoryModel->id)
                ->where('products.is_active', true)
                ->where('products.published', true)
                ->distinct()
                ->orderBy('standards.code')
                ->select('standards.id', 'standards.code')
                ->get();
        }

        // Get available diameters for current category
        $diameters = collect();
        if ($categoryModel) {
            $diameters = DB::table('diameters')
                ->join('product_connections', 'diameters.id', '=', 'product_connections.diameter_id')
                ->join('products', 'product_connections.product_id', '=', 'products.id')
                ->where('products.category_id', $categoryModel->id)
                ->where('products.is_active', true)
                ->where('products.published', true)
                ->distinct()
                ->orderBy('diameters.value')
                ->select('diameters.id', 'diameters.value')
                ->get();
        }

        // Get available product types for current category
        $productTypes = collect();
        if ($categoryModel) {
            $productTypes = ProductType::where('is_active', true)
                ->where('category_id', $categoryModel->id)
                ->whereHas('products', fn ($q) => $q->where('is_active', true)->where('published', true))
                ->orderBy('name')
                ->get(['id', 'name']);
        }

        return Inertia::render('store/catalog/Index', [
            'products' => $products,
            'categories' => $categories,
            'characteristics' => $characteristics,
            'characteristic_values' => $charValues,
            'favorite_product_ids' => $favoriteProductIds,
            'standards' => $standards,
            'diameters' => $diameters,
            'product_types' => $productTypes,
            'filters' => [
                'category' => $categoryId,
                'standard' => $standardId,
                'diameter' => $diameterId,
                'product_type' => $productTypeId,
                'stock_status' => $stockStatus,
                'min_price' => $minPrice,
                'max_price' => $maxPrice,
                'characteristics' => $selectedCharacteristics,
                'sort' => $sort,
                'direction' => $direction,
                'search' => $search,
            ],
        ])->with([
            'title' => 'Каталог товаров — Гидровик',
            'description' => 'Промышленное гидравлическое оборудование, фитинги, трубы и комплектующие. Поиск по категориям, производителям и техническим характеристикам.',
            'image' => url('/og-product.png'),
            'type' => 'website',
            'url' => url()->current(),
            'canonical' => url()->current(),
        ]);
    }
}
