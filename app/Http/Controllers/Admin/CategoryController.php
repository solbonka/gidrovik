<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreCategoryRequest;
use App\Http\Requests\Admin\UpdateCategoryCharacteristicsRequest;
use App\Http\Requests\Admin\UpdateCategoryRequest;
use App\Models\Category;
use App\Models\Characteristic;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class CategoryController extends Controller
{
    public function index(): Response
    {
        $categories = Category::query()
            ->withCount([
                'products',
                'productTypes',
                'characteristics',
            ])
            ->orderBy('name')
            ->paginate(20)
            ->withQueryString();

        return Inertia::render('admin/categories/Index', [
            'categories' => $categories,
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('admin/categories/Create');
    }

    public function store(
        StoreCategoryRequest $request,
    ): RedirectResponse {
        Category::query()->create($request->validated());

        return to_route('admin.categories.index')
            ->with('success', 'Категория успешно создана.');
    }

    public function edit(Category $category): Response
    {
        return Inertia::render('admin/categories/Edit', [
            'category' => $category,
        ]);
    }

    public function update(
        UpdateCategoryRequest $request,
        Category $category,
    ): RedirectResponse {
        $category->update($request->validated());

        return to_route('admin.categories.index')
            ->with('success', 'Категория успешно обновлена.');
    }

    public function destroy(Category $category): RedirectResponse
    {
        if (
            $category->products()->exists()
            || $category->productTypes()->exists()
        ) {
            return to_route('admin.categories.index')
                ->with(
                    'error',
                    'Нельзя удалить категорию, которая используется товарами или типами товаров.',
                );
        }

        $category->delete();

        return to_route('admin.categories.index')
            ->with('success', 'Категория удалена.');
    }

    public function characteristics(Category $category): Response
    {
        $characteristics = Characteristic::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'slug', 'type', 'unit']);

        $assignedCharacteristics = $category
            ->characteristics()
            ->get()
            ->keyBy('id');

        return Inertia::render('admin/categories/Characteristics', [
            'category' => $category->only([
                'id',
                'name',
                'slug',
            ]),
            'characteristics' => $characteristics->map(
                function (Characteristic $characteristic) use (
                    $assignedCharacteristics
                ): array {
                    $assigned = $assignedCharacteristics->get(
                        $characteristic->id
                    );

                    return [
                        'id' => $characteristic->id,
                        'name' => $characteristic->name,
                        'slug' => $characteristic->slug,
                        'type' => $characteristic->type,
                        'unit' => $characteristic->unit,
                        'assigned' => $assigned !== null,
                        'is_required' => $assigned?->pivot->is_required ?? false,
                        'sort_order' => $assigned?->pivot->sort_order ?? 0,
                    ];
                }
            )->values(),
        ]);
    }

    public function updateCharacteristics(
        UpdateCategoryCharacteristicsRequest $request,
        Category $category,
    ): RedirectResponse {
        $characteristics = collect(
            $request->validated('characteristics', [])
        )->keyBy('id');

        $syncData = $characteristics->mapWithKeys(
            function (array $characteristic, int|string $id): array {
                return [
                    $id => [
                        'is_required' => $characteristic['is_required'],
                        'sort_order' => $characteristic['sort_order'],
                    ],
                ];
            }
        )->all();

        $category->characteristics()->sync($syncData);

        return to_route('admin.categories.index')
            ->with(
                'success',
                'Характеристики категории успешно обновлены.'
            );
    }
}
