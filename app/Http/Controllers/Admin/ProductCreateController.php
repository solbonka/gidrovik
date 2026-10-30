<?php

namespace App\Http\Controllers\Admin;

use App\Models\Category;
use App\Models\CharacteristicValue;
use App\Models\Country;
use App\Models\Diameter;
use App\Models\Manufacturer;
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
            'manufacturers' => Manufacturer::query()
                ->where('is_active', true)
                ->orderBy('name')
                ->get(['id', 'name']),
            'countries' => Country::query()
                ->orderBy('name')
                ->get(['id', 'name']),
        ]);
    }

    public function characteristics(int $category): JsonResponse
    {
        $categoryModel = Category::query()
            ->where('is_active', true)
            ->findOrFail($category);

        $characteristics = $categoryModel->characteristics()
            ->where('is_active', true)
            ->get([
                'characteristics.id',
                'characteristics.name',
                'characteristics.slug',
                'characteristics.type',
                'characteristics.unit',
            ]);

        // Load values for select-type characteristics
        $selectIds = $characteristics->where('type', 'select')->pluck('id')->toArray();

        $valuesBySlug = [];
        if (!empty($selectIds)) {
            $values = CharacteristicValue::whereIn('characteristic_id', $selectIds)
                ->orderBy('sort_order')
                ->orderBy('value')
                ->get();

            $valuesBySlug = $values->groupBy('characteristic_id')
                ->map(fn ($items) => $items->map(fn ($item) => [
                    'id' => $item->id,
                    'value' => $item->value,
                ]))
                ->toArray();
        }

        return response()->json([
            'characteristics' => $characteristics,
            'values' => $valuesBySlug,
        ]);
    }
}
