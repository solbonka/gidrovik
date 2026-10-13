<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreProductRequest;
use App\Models\Category;
use App\Models\Product;
use App\Models\ProductType;
use App\Models\Diameter;
use App\Models\Standard;
use App\Models\StockMovement;
use App\Models\Thread;
use App\Http\Requests\Admin\UpdateProductRequest;
use App\Services\Admin\ProductService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class ProductController extends Controller
{
    public function index(Request $request): Response
    {
        $products = Product::query()
            ->with([
                'category:id,name',
                'productType:id,name',
            ])
            ->when(
                $request->filled('search'),
                fn ($query) => $query->where(function ($query) use ($request) {
                    $search = $request->string('search')->trim()->toString();

                    $query
                        ->where('name', 'like', "%{$search}%")
                        ->orWhere('sku', 'like', "%{$search}%");
                }),
            )
            ->when(
                $request->filled('category_id'),
                fn ($query) => $query->where(
                    'category_id',
                    $request->integer('category_id'),
                ),
            )
            ->when(
                $request->filled('product_type_id'),
                fn ($query) => $query->where(
                    'product_type_id',
                    $request->integer('product_type_id'),
                ),
            )
            ->addSelect([
                'stock_quantity' => DB::table('product_location')
                    ->selectRaw('COALESCE(SUM(quantity), 0)')
                    ->whereColumn(
                        'product_location.product_id',
                        'products.id',
                    ),
            ])
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/products/Index', [
            'products' => $products,
            'categories' => Category::query()
                ->where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'name']),
            'productTypes' => ProductType::query()
                ->where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'category_id', 'name']),
            'filters' => [
                'search' => $request->string('search')->toString(),
                'category_id' => $request->integer('category_id') ?: null,
                'product_type_id' => $request->integer('product_type_id') ?: null,
            ],
        ]);
    }

    public function show(Product $product): Response
    {
        $product->load([
            'category:id,name,slug',
            'productType:id,name,slug',
            'characteristicValues.characteristic:id,name,slug,type,unit',
            'connections.standard:id,code,name',
            'connections.diameter:id,value,unit',
            'connections.thread:id,system,designation,name',
            'locations.rack:id,code,name',
        ]);

        $stockQuantity = bcadd(
            (string) DB::table('product_location')
                ->where('product_id', $product->id)
                ->sum('quantity'),
            '0',
            3,
        );

        return Inertia::render('admin/products/Show', [
            'product' => [
                'id' => $product->id,
                'name' => $product->name,
                'sku' => $product->sku,
                'minimum_stock' => $product->minimum_stock,
                'angle' => $product->angle,
                'description' => $product->description,
                'is_active' => $product->is_active,

                'category' => $product->category
                    ? [
                        'id' => $product->category->id,
                        'name' => $product->category->name,
                        'slug' => $product->category->slug,
                    ]
                    : null,

                'product_type' => $product->productType
                    ? [
                        'id' => $product->productType->id,
                        'name' => $product->productType->name,
                        'slug' => $product->productType->slug,
                    ]
                    : null,

                'stock_quantity' => $stockQuantity,

                'characteristics' => $product->characteristicValues
                    ->map(fn ($item) => [
                        'id' => $item->id,
                        'characteristic_id' => $item->characteristic_id,
                        'name' => $item->characteristic->name,
                        'slug' => $item->characteristic->slug,
                        'type' => $item->characteristic->type,
                        'unit' => $item->characteristic->unit,
                        'value' => $item->value,
                    ])
                    ->values(),

                'connections' => $product->connections
                    ->map(fn ($connection) => [
                        'id' => $connection->id,
                        'position' => $connection->position,
                        'standard' => $connection->standard
                            ? [
                                'id' => $connection->standard->id,
                                'code' => $connection->standard->code,
                                'name' => $connection->standard->name,
                            ]
                            : null,
                        'diameter' => $connection->diameter
                            ? [
                                'id' => $connection->diameter->id,
                                'value' => $connection->diameter->value,
                                'unit' => $connection->diameter->unit,
                            ]
                            : null,
                        'thread' => $connection->thread
                            ? [
                                'id' => $connection->thread->id,
                                'system' => $connection->thread->system,
                                'designation' => $connection->thread->designation,
                                'name' => $connection->thread->name,
                            ]
                            : null,
                    ])
                    ->values(),

                'locations' => $product->locations
                    ->map(fn ($location) => [
                        'id' => $location->id,
                        'code' => $location->code,
                        'rack' => [
                            'id' => $location->rack->id,
                            'code' => $location->rack->code,
                            'name' => $location->rack->name,
                        ],
                        'number' => $location->number,
                        'quantity' => bcadd(
                            (string) $location->pivot->quantity,
                            '0',
                            3,
                        ),
                    ])
                    ->values(),
            ],
        ]);
    }

    public function store(
        StoreProductRequest $request,
        ProductService $productService,
    ): RedirectResponse {
        $productService->create($request->validated());

        return to_route('admin.products.index')
            ->with('success', 'Товар успешно создан.');
    }

    public function edit(Product $product): Response
    {
        $product->load([
            'characteristicValues',
            'connections',
        ]);

        $categories = Category::query()
            ->where('is_active', true)
            ->with([
                'productTypes' => fn ($query) => $query
                    ->where('is_active', true)
                    ->orderBy('name'),

                'characteristics' => fn ($query) => $query
                    ->where('is_active', true)
                    ->orderBy('category_characteristic.sort_order'),
            ])
            ->orderBy('name')
            ->get();

        return Inertia::render('admin/products/Edit', [
            'product' => [
                'id' => $product->id,
                'category_id' => $product->category_id,
                'product_type_id' => $product->product_type_id,
                'name' => $product->name,
                'sku' => $product->sku,
                'minimum_stock' => $product->minimum_stock,
                'angle' => $product->angle,
                'description' => $product->description,
                'is_active' => $product->is_active,

                'characteristics' => $product->characteristicValues
                    ->mapWithKeys(fn ($item) => [
                        (string) $item->characteristic_id => $item->value,
                    ]),

                'connections' => $product->connections
                    ->map(fn ($connection) => [
                        'position' => $connection->position,
                        'standard_id' => $connection->standard_id,
                        'diameter_id' => $connection->diameter_id,
                        'thread_id' => $connection->thread_id,
                    ])
                    ->values(),
            ],

            'categories' => $categories,

            'standards' => Standard::query()
                ->where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'code', 'name']),

            'diameters' => Diameter::query()
                ->where('is_active', true)
                ->orderBy('value')
                ->get(['id', 'value', 'unit']),

            'threads' => Thread::query()
                ->where('is_active', true)
                ->orderBy('system')
                ->orderBy('designation')
                ->get([
                    'id',
                    'system',
                    'designation',
                    'name',
                ]),
        ]);
    }

    public function update(
        UpdateProductRequest $request,
        Product $product,
        ProductService $productService,
    ): RedirectResponse {
        $productService->update(
            $product,
            $request->validated(),
        );

        return to_route('admin.products.show', $product)
            ->with('success', 'Товар успешно обновлён.');
    }

    public function destroy(Product $product): RedirectResponse
    {
        return DB::transaction(function () use ($product): RedirectResponse {
            $lockedProduct = Product::query()
                ->whereKey($product->id)
                ->lockForUpdate()
                ->firstOrFail();

            $hasStock = DB::table('product_location')
                ->where('product_id', $lockedProduct->id)
                ->where('quantity', '>', 0)
                ->exists();

            if ($hasStock) {
                return back()->with(
                    'error',
                    'Товар нельзя удалить: на складе есть остаток.',
                );
            }

            $hasMovements = StockMovement::query()
                ->where('product_id', $lockedProduct->id)
                ->exists();

            if ($hasMovements) {
                return back()->with(
                    'error',
                    'Товар нельзя удалить: по нему есть история складских движений.',
                );
            }

            $lockedProduct->delete();

            return to_route('admin.products.index')
                ->with('success', 'Товар успешно удалён.');
        });
    }
}
