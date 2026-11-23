<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ProductSegmentStatus;
use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductSegment;
use App\Services\Admin\ProductSegmentService;
use App\Services\Admin\StockMovementService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class StockOperationApiController extends Controller
{
    public function __construct(
        private readonly StockMovementService $stockMovementService,
        private readonly ProductSegmentService $productSegmentService,
    ) {}

    public function execute(Request $request): RedirectResponse
    {
        $operation = $request->input('operation');

        $productId = (int) $request->input('product_id');
        $isLength = $productId > 0
            && Product::query()->whereKey($productId)->first()?->usesLengthStock() === true;

        $baseRules = [
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'comment' => ['nullable', 'string'],
        ];

        $operationRules = $isLength
            ? $this->lengthOperationRules($operation)
            : $this->quantityOperationRules($operation);

        $allRules = array_merge($baseRules, $operationRules);

        $validator = Validator::make($request->all(), $allRules);
        $validator->validate();

        $validated = $validator->validated();

        if ($isLength) {
            return $this->executeLengthOperation($request, $operation, $validated);
        }

        $movement = match ($operation) {
            'receipt' => $this->stockMovementService->receipt(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'write_off' => $this->stockMovementService->writeOff(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'transfer' => $this->stockMovementService->transfer(
                productId: (int) $validated['product_id'],
                fromLocationId: (int) $validated['from_location_id'],
                toLocationId: (int) $validated['to_location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'return' => $this->stockMovementService->returnStock(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                quantity: (string) $validated['quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
            'inventory' => $this->stockMovementService->inventory(
                productId: (int) $validated['product_id'],
                locationId: (int) $validated['location_id'],
                actualQuantity: (string) $validated['actual_quantity'],
                comment: $validated['comment'] ?? null,
                userId: $request->user()?->id,
            ),
        };

        return redirect()->back()->with('toast', [
            'type' => 'success',
            'message' => 'Операция успешно выполнена.',
        ]);
    }

    public function currentLocationProducts(Request $request): JsonResponse
    {
        $locationId = (int) ($request->route('location') ?? $request->input('location_id'));

        $validator = Validator::make(['location_id' => $locationId], [
            'location_id' => ['required', 'integer', 'exists:locations,id'],
        ]);
        $validator->validate();

        $products = DB::table('product_location')
            ->join('products', 'product_location.product_id', '=', 'products.id')
            ->where('product_location.location_id', $locationId)
            ->where('product_location.quantity', '>', 0)
            ->select([
                'products.id',
                'products.name',
                'products.code',
                'products.article',
                'products.stock_mode',
                'product_location.quantity',
            ])
            ->get();

        // Для товаров с учётом по отрезкам подгружаем физические куски
        $lengthProductIds = $products
            ->filter(fn ($item) => $item->stock_mode === 'length')
            ->pluck('id')
            ->all();

        $segmentsByProduct = [];

        if ($lengthProductIds !== []) {
            $segmentsByProduct = DB::table('product_segments')
                ->where('location_id', $locationId)
                ->whereIn('product_id', $lengthProductIds)
                ->whereIn('status', ['available', 'reserved', 'quarantined'])
                ->orderBy('length_mm')
                ->get(['product_id', 'id', 'length_mm', 'status'])
                ->groupBy('product_id');
        }

        $products = $products->map(function ($item) use ($segmentsByProduct) {
            $segments = ($segmentsByProduct[$item->id] ?? collect())->map(fn ($s) => [
                'id' => $s->id,
                'length_mm' => (float) $s->length_mm,
                'status' => $s->status,
            ])->values();

            return [
                'id' => $item->id,
                'name' => $item->name,
                'code' => $item->code ?? null,
                'article' => $item->article ?? null,
                'quantity' => rtrim(rtrim(bcadd((string) $item->quantity, '0', 3), '0'), '.'),
                'stock_mode' => $item->stock_mode ?? 'quantity',
                'segments' => $segments,
            ];
        });

        return response()->json([
            'products' => $products,
        ]);
    }

    public function productLocation(Request $request): JsonResponse
    {
        $productId = (int) ($request->route('product') ?? $request->input('product_id'));

        $validator = Validator::make(['product_id' => $productId], [
            'product_id' => ['required', 'integer', 'exists:products,id'],
        ]);
        $validator->validate();

        $locations = DB::table('product_location')
            ->join('locations', 'product_location.location_id', '=', 'locations.id')
            ->join('racks', 'locations.rack_id', '=', 'racks.id')
            ->where('product_location.product_id', $productId)
            ->where('product_location.quantity', '>', 0)
            ->select([
                'locations.id',
                'locations.number',
                'racks.code as rack_code',
                'product_location.quantity',
            ])
            ->get();

        // Для товаров с учётом по отрезкам подгружаем куски по ячейкам
        $isLength = DB::table('products')
            ->where('id', $productId)
            ->value('stock_mode') === 'length';

        $segmentsByLocation = [];

        if ($isLength) {
            $segmentsByLocation = DB::table('product_segments')
                ->where('product_id', $productId)
                ->whereIn('status', ['available', 'reserved', 'quarantined'])
                ->orderBy('length_mm')
                ->get(['location_id', 'id', 'length_mm', 'status'])
                ->groupBy('location_id');
        }

        $locations = $locations->map(function ($item) use ($isLength, $segmentsByLocation) {
            $segments = $isLength
                ? ($segmentsByLocation[$item->id] ?? collect())->map(fn ($s) => [
                    'id' => $s->id,
                    'length_mm' => (float) $s->length_mm,
                    'status' => $s->status,
                ])->values()
                : [];

            return [
                'id' => $item->id,
                'number' => $item->number,
                'code' => $item->rack_code.'-'.$item->number,
                'quantity' => rtrim(rtrim(bcadd((string) $item->quantity, '0', 3), '0'), '.'),
                'segments' => $segments,
            ];
        });

        return response()->json([
            'locations' => $locations,
            'stock_mode' => $isLength ? 'length' : 'quantity',
        ]);
    }

    /**
     * @return array<string, array<int, string>>
     */
    private function quantityOperationRules(string $operation): array
    {
        return match ($operation) {
            'receipt', 'write_off', 'return' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'quantity' => ['required', 'numeric', 'min:0'],
            ],
            'transfer' => [
                'from_location_id' => ['required', 'integer', 'exists:locations,id'],
                'to_location_id' => ['required', 'integer', 'exists:locations,id'],
                'quantity' => ['required', 'numeric', 'min:0'],
            ],
            'inventory' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'actual_quantity' => ['required', 'numeric', 'min:0'],
            ],
            default => throw new \InvalidArgumentException('Unknown operation'),
        };
    }

    /**
     * @return array<string, array<int, string>>
     */
    private function lengthOperationRules(string $operation): array
    {
        return match ($operation) {
            'receipt', 'return' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'segments' => ['required', 'array', 'min:1'],
                'segments.*.length_mm' => ['required', 'numeric', 'gt:0'],
            ],
            'write_off' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'segment_ids' => ['required', 'array', 'min:1'],
                'segment_ids.*' => ['required', 'integer'],
            ],
            'transfer' => [
                'from_location_id' => ['required', 'integer', 'exists:locations,id'],
                'to_location_id' => ['required', 'integer', 'exists:locations,id'],
                'segment_ids' => ['required', 'array', 'min:1'],
                'segment_ids.*' => ['required', 'integer'],
            ],
            'inventory' => [
                'location_id' => ['required', 'integer', 'exists:locations,id'],
                'segments' => ['required', 'array', 'min:1'],
                'segments.*.segment_id' => ['required', 'integer'],
                'segments.*.length_mm' => ['required', 'numeric', 'gt:0'],
            ],
            default => throw new \InvalidArgumentException('Unknown operation'),
        };
    }

    /**
     * Операции для товаров с учётом по отрезкам (stock_mode = length).
     * Длины отрезков передаются в миллиметрах.
     *
     * @param  array<string, mixed>  $validated
     */
    private function executeLengthOperation(
        Request $request,
        string $operation,
        array $validated,
    ): RedirectResponse {
        $productId = (int) $validated['product_id'];
        $comment = $validated['comment'] ?? null;
        $userId = $request->user()?->id;
        $service = $this->productSegmentService;

        match ($operation) {
            'receipt', 'return' => $service->receiptSegments(
                productId: $productId,
                items: array_map(
                    fn (array $segment): array => [
                        'location_id' => (int) $validated['location_id'],
                        'length_mm' => (string) $segment['length_mm'],
                    ],
                    $validated['segments'],
                ),
                comment: $comment,
                userId: $userId,
            ),
            'write_off' => $this->writeOffCellSegments(
                $productId,
                (int) $validated['location_id'],
                $validated['segment_ids'],
                $comment,
                $userId,
            ),
            'transfer' => $this->transferCellSegments(
                $productId,
                (int) $validated['from_location_id'],
                (int) $validated['to_location_id'],
                $validated['segment_ids'],
                $comment,
                $userId,
            ),
            'inventory' => $this->inventoryCellSegments(
                $productId,
                (int) $validated['location_id'],
                $validated['segments'],
                $comment,
                $userId,
            ),
            default => throw new \InvalidArgumentException('Unknown operation'),
        };

        return redirect()->back()->with('toast', [
            'type' => 'success',
            'message' => 'Операция успешно выполнена.',
        ]);
    }

    /**
     * @param  list<int|string>  $segmentIds
     */
    private function assertSegmentsInLocation(
        int $productId,
        int $locationId,
        array $segmentIds,
    ): void {
        $segmentIds = array_values(array_unique(array_map('intval', $segmentIds)));

        $found = ProductSegment::query()
            ->where('product_id', $productId)
            ->where('location_id', $locationId)
            ->whereIn('id', $segmentIds)
            ->count();

        if ($found !== count($segmentIds)) {
            throw ValidationException::withMessages([
                'segment_ids' => 'Часть выбранных отрезков отсутствует в этой ячейке.',
            ]);
        }
    }

    /**
     * @param  list<int|string>  $segmentIds
     */
    private function writeOffCellSegments(
        int $productId,
        int $locationId,
        array $segmentIds,
        ?string $comment,
        ?int $userId,
    ): void {
        $this->assertSegmentsInLocation($productId, $locationId, $segmentIds);

        $this->productSegmentService->writeOffSegments(
            $productId,
            array_values(array_unique(array_map('intval', $segmentIds))),
            $comment,
            $userId,
        );
    }

    /**
     * @param  list<int|string>  $segmentIds
     */
    private function transferCellSegments(
        int $productId,
        int $fromLocationId,
        int $toLocationId,
        array $segmentIds,
        ?string $comment,
        ?int $userId,
    ): void {
        $this->assertSegmentsInLocation($productId, $fromLocationId, $segmentIds);

        $this->productSegmentService->transferSegments(
            productId: $productId,
            segmentIds: array_values(array_unique(array_map('intval', $segmentIds))),
            toLocationId: $toLocationId,
            comment: $comment,
            userId: $userId,
        );
    }

    /**
     * Инвентаризация по отрезкам: segments — фактически найденные куски
     * [{segment_id, length_mm}]. Отрезки, не указанные в списке, списываются;
     * у указанных корректируется длина. Зарезервированные отрезки не трогаем.
     *
     * @param  list<array{segment_id: int|string, length_mm: mixed}>  $items
     */
    private function inventoryCellSegments(
        int $productId,
        int $locationId,
        array $items,
        ?string $comment,
        ?int $userId,
    ): void {
        DB::transaction(function () use ($productId, $locationId, $items, $comment, $userId): void {
            $statuses = array_map(
                fn (ProductSegmentStatus $status) => $status->value,
                ProductSegmentStatus::stockCounting(),
            );

            $segments = ProductSegment::query()
                ->where('product_id', $productId)
                ->where('location_id', $locationId)
                ->whereIn('status', $statuses)
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            $inputIds = [];

            foreach ($items as $index => $item) {
                $segmentId = (int) $item['segment_id'];
                $inputIds[$segmentId] = true;

                $segment = $segments->get($segmentId);

                if ($segment === null) {
                    throw ValidationException::withMessages([
                        "segments.{$index}.segment_id" => 'Отрезок не найден в этой ячейке.',
                    ]);
                }

                if ($segment->status === ProductSegmentStatus::RESERVED) {
                    throw ValidationException::withMessages([
                        "segments.{$index}.segment_id" => "Отрезок #{$segment->id} зарезервирован под заказ.",
                    ]);
                }

                $newLengthMm = bcadd((string) $item['length_mm'], '0', 3);
                $oldLengthMm = bcadd((string) $segment->length_mm, '0', 3);

                if (bccomp($newLengthMm, $oldLengthMm, 3) !== 0) {
                    $this->productSegmentService->correctSegmentLength(
                        $productId,
                        $segment->id,
                        $newLengthMm,
                        $comment,
                        $userId,
                    );
                }
            }

            $missingIds = $segments
                ->reject(fn (ProductSegment $segment) => isset($inputIds[$segment->id]))
                ->where('status', '!=', ProductSegmentStatus::RESERVED->value)
                ->pluck('id')
                ->all();

            if ($missingIds !== []) {
                $this->productSegmentService->writeOffSegments(
                    $productId,
                    $missingIds,
                    $comment !== null ? trim($comment.' (инвентаризация)') : 'Инвентаризация',
                    $userId,
                );
            }
        }, attempts: 3);
    }
}
