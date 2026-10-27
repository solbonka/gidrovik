<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class SearchController extends Controller
{
    public function __invoke(Request $request): Response
    {
        $query = $request->input('q', '');

        $products = collect();
        $total = 0;

        if (strlen($query) >= 2) {
            $words = preg_split('/\s+/u', mb_strtolower(trim($query), 'UTF-8'), -1, PREG_SPLIT_NO_EMPTY);

            $results = Product::query()
                ->where('is_active', true)
                ->where('published', true)
                ->where(function ($q) use ($words) {
                    foreach ($words as $word) {
                        $word = addcslashes($word, '%_\\');
                        $q->where(function ($q) use ($word) {
                            $q->whereRaw('LOWER(name) LIKE ?', ["%{$word}%"])
                                ->orWhereRaw('LOWER(sku) LIKE ?', ["%{$word}%"])
                                ->orWhereRaw("LOWER(COALESCE(description, '')) LIKE ?", ["%{$word}%"])
                                ->orWhereHas('category', function ($q) use ($word) {
                                    $q->whereRaw('LOWER(name) LIKE ?', ["%{$word}%"]);
                                })
                                ->orWhereHas('productType', function ($q) use ($word) {
                                    $q->whereRaw('LOWER(name) LIKE ?', ["%{$word}%"]);
                                })
                                ->orWhereHas('characteristicValues', function ($q) use ($word) {
                                    $q->whereRaw('LOWER(value) LIKE ?', ["%{$word}%"])
                                      ->orWhereHas('characteristic', function ($q) use ($word) {
                                          $q->whereRaw('LOWER(name) LIKE ?', ["%{$word}%"]);
                                      });
                                });
                        });
                    }
                })
                ->with(['category', 'images'])
                ->get();

            $products = $results->map(fn (Product $product) => [
                'id' => $product->id,
                'name' => $product->name,
                'slug' => $product->slug,
                'sku' => $product->sku,
                'price' => $product->retail_price ?? '0',
                'image_path' => $product->images->first()?->getUrlForSize('thumbnail'),
                'stock_status' => $product->stock_status,
                'category' => $product->category?->name,
            ]);

            $total = $results->count();
        }

        return Inertia::render('store/search/Index', [
            'query' => $query,
            'products' => $products,
            'total' => $total,
        ]);
    }
}
