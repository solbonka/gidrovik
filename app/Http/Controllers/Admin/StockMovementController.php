<?php

namespace App\Http\Controllers\Admin;

use App\Enums\StockMovementType;
use App\Http\Controllers\Controller;
use App\Models\StockMovement;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class StockMovementController extends Controller
{
    public function index(Request $request): Response
    {
        $validated = $request->validate([
            'product_id' => ['nullable', 'integer', 'exists:products,id'],
            'type' => ['nullable', 'string', 'in:receipt,transfer,write_off,return,inventory'],
            'search' => ['nullable', 'string', 'max:255'],
        ]);

        $productId = $validated['product_id'] ?? null;
        $type = $validated['type'] ?? '';
        $search = trim($validated['search'] ?? '');

        $movements = StockMovement::query()
            ->with([
                'product:id,name,code,article',
                'fromLocation.rack:id,code,name',
                'toLocation.rack:id,code,name',
                'user:id,name',
            ])
            ->when(
                $productId,
                fn ($query) => $query->where('product_id', $productId),
            )
            ->when(
                $type !== '',
                fn ($query) => $query->where('type', $type),
            )
            ->when(
                $search !== '',
                function ($query) use ($search): void {
                    $search = addcslashes($search, '%_');
                    $query->whereHas(
                        'product',
                        fn ($productQuery) => $productQuery->where(
                            function ($nestedQuery) use ($search): void {
                                $nestedQuery
                                    ->where('name', 'like', "%{$search}%")
                                    ->orWhere('code', 'like', "%{$search}%")
                                    ->orWhere('article', 'like', "%{$search}%");
                            },
                        ),
                    );
                },
            )
            ->latest('id')
            ->paginate(25)
            ->withQueryString()
            ->through(fn (StockMovement $movement): array => [
                'id' => $movement->id,
                'type' => $movement->type->value,
                'type_label' => $movement->type->label(),
                'quantity' => $movement->quantity,
                'comment' => $movement->comment,
                'created_at' => $movement->created_at?->format('d.m.Y H:i'),
                'product' => [
                    'id' => $movement->product->id,
                    'name' => $movement->product->name,
                    'code' => $movement->product->code,
                    'article' => $movement->product->article,
                ],
                'from_location' => $movement->fromLocation
                    ? [
                        'code' => $movement->fromLocation->code,
                    ]
                    : null,
                'to_location' => $movement->toLocation
                    ? [
                        'code' => $movement->toLocation->code,
                    ]
                    : null,
                'user' => $movement->user?->name,
            ]);

        return Inertia::render('admin/stock/Movements', [
            'movements' => $movements,
            'filters' => [
                'product_id' => $productId ? (string) $productId : '',
                'type' => $type,
                'search' => $search,
            ],
            'types' => collect(StockMovementType::cases())
                ->map(fn (StockMovementType $type): array => [
                    'value' => $type->value,
                    'label' => $type->label(),
                ])
                ->values(),
        ]);
    }

    public function destroy(StockMovement $movement): RedirectResponse
    {
        $movement->delete();

        return to_route('admin.stock.movements.index')
            ->with('success', 'Запись удалена из журнала.');
    }
}
