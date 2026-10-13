<?php

namespace App\Http\Controllers\Admin;

use App\Models\Category;
use App\Models\Diameter;
use App\Models\Standard;
use App\Models\Thread;
use Illuminate\Http\JsonResponse;
use Inertia\Inertia;
use Inertia\Response;

class ProductCreateController
{
    public function create(): Response
    {
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

        return Inertia::render('admin/products/Create', [
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
                ->get(['id', 'system', 'designation', 'name']),
        ]);
    }

    public function characteristics(int $category): JsonResponse
    {
        $categoryModel = Category::query()
            ->where('is_active', true)
            ->findOrFail($category);

        return response()->json(
            $categoryModel->characteristics()
                ->where('is_active', true)
                ->get([
                    'characteristics.id',
                    'characteristics.name',
                    'characteristics.slug',
                    'characteristics.type',
                    'characteristics.unit',
                ])
        );
    }
}
