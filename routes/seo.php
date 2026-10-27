<?php

use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Route;

/* |--------------------------------------------------------------------------
| SEO Routes (public, no auth)
|-------------------------------------------------------------------------- */

// robots.txt
Route::get('/robots.txt', function (Request $request) {
    return response(
        "User-agent: *\nAllow: /\n\nSitemap: " . url('/sitemap.xml'),
        200,
        ['Content-Type' => 'text/plain']
    );
})->name('robots.txt');

// sitemap.xml
Route::get('/sitemap.xml', function () {
    $products = Product::where('is_active', true)
        ->where('published', true)
        ->select('id', 'updated_at', 'slug')
        ->orderByDesc('updated_at')
        ->get();

    $categories = Category::where('is_active', true)
        ->select('id', 'updated_at', 'slug')
        ->get();

    $xml = '<?xml version="1.0" encoding="UTF-8"?>';
    $xml .= '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">';

    // Static pages
    $staticPages = [
        ['loc' => url('/'), 'priority' => '1.0', 'freq' => 'daily'],
        ['loc' => url('/catalog'), 'priority' => '0.9', 'freq' => 'daily'],
        ['loc' => url('/delivery'), 'priority' => '0.5', 'freq' => 'monthly'],
        ['loc' => url('/payment'), 'priority' => '0.5', 'freq' => 'monthly'],
        ['loc' => url('/returns'), 'priority' => '0.5', 'freq' => 'monthly'],
        ['loc' => url('/privacy'), 'priority' => '0.5', 'freq' => 'monthly'],
    ];

    foreach ($staticPages as $page) {
        $xml .= '<url>';
        $xml .= '<loc>' . e($page['loc']) . '</loc>';
        $xml .= '<lastmod>' . now()->format('Y-m-d') . '</lastmod>';
        $xml .= '<changefreq>' . $page['freq'] . '</changefreq>';
        $xml .= '<priority>' . $page['priority'] . '</priority>';
        $xml .= '</url>';
    }

    // Categories
    foreach ($categories as $category) {
        $xml .= '<url>';
        $xml .= '<loc>' . e(url('/catalog?category=' . $category->slug)) . '</loc>';
        $xml .= '<lastmod>' . $category->updated_at->format('Y-m-d') . '</lastmod>';
        $xml .= '<changefreq>daily</changefreq>';
        $xml .= '<priority>0.8</priority>';
        $xml .= '</url>';
    }

    // Products
    foreach ($products as $product) {
        $xml .= '<url>';
        $xml .= '<loc>' . e(url('/products/' . $product->slug)) . '</loc>';
        $xml .= '<lastmod>' . $product->updated_at->format('Y-m-d') . '</lastmod>';
        $xml .= '<changefreq>weekly</changefreq>';
        $xml .= '<priority>0.7</priority>';
        $xml .= '</url>';
    }

    $xml .= '</urlset>';

    return response($xml, 200, [
        'Content-Type' => 'application/xml',
    ]);
})->name('sitemap.xml');
