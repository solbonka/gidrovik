<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreProductTypeRequest;
use App\Http\Requests\Admin\UpdateProductTypeRequest;
use App\Models\Category;
use App\Models\ProductType;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class ProductTypeController extends Controller
{
    public function index(): Response
    {
        $productTypes = ProductType::query()
            ->with('category:id,name')
            ->withCount('products')
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/product-types/Index', [
            'productTypes' => $productTypes,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/product-types/Create', [
            'categories' => $this->categories(),
        ]);
    }

    public function store(
        StoreProductTypeRequest $request,
    ): RedirectResponse {
        ProductType::query()->create($request->validated());

        return to_route('admin.product-types.index')
            ->with('success', 'Тип товара успешно создан.');
    }

    public function edit(ProductType $productType): Response
    {
        return Inertia::render('admin/product-types/Edit', [
            'productType' => $productType,
            'categories' => $this->categories(),
        ]);
    }

    public function update(
        UpdateProductTypeRequest $request,
        ProductType $productType,
    ): RedirectResponse {
        $productType->update($request->validated());

        return to_route('admin.product-types.index')
            ->with('success', 'Тип товара успешно обновлён.');
    }

    public function destroy(ProductType $productType): RedirectResponse
    {
        if ($productType->products()->exists()) {
            return to_route('admin.product-types.index')
                ->with(
                    'error',
                    'Нельзя удалить тип товара, который используется товарами.',
                );
        }

        $productType->delete();

        return to_route('admin.product-types.index')
            ->with('success', 'Тип товара удалён.');
    }

    private function categories()
    {
        return Category::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name']);
    }
}
