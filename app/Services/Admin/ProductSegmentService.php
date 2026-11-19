<?php

namespace App\Services\Admin;

use App\Enums\ProductSegmentStatus;
use App\Enums\SegmentMovementType;
use App\Enums\StockMovementType;
use App\Models\Location;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\ProductSegment;
use App\Models\SegmentMovement;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ProductSegmentService
{
    private const MAX_LENGTH_MM = '999999999.999';

    /**
     * Поступление одного отрезка. Используется StockMovementService::receipt
     * для товаров с учётом по отрезкам (быстрое поступление без списка длин).
     *
     * @param  string  $quantity  Количество в единицах товара (метры для unit = 'м')
     */
    public function receiptSingle(
        int $productId,
        int $locationId,
        string $quantity,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        $lengthMm = bcmul($quantity, '1000', 3);

        return $this->receiptSegments(
            $productId,
            [
                ['location_id' => $locationId, 'length_mm' => $lengthMm],
            ],
            $comment,
            $userId,
        );
    }

    /**
     * Поступление произвольного списка физических отрезков.
     *
     * @param  list<array{location_id?: int|string|null, length_mm?: mixed}>  $items
     */
    public function receiptSegments(
        int $productId,
        array $items,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        return DB::transaction(function () use (
            $productId,
            $items,
            $comment,
            $userId,
        ): StockMovement {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $product->usesLengthStock()) {
                throw ValidationException::withMessages([
                    'product_id' => 'Товар не использует учёт по отрезкам.',
                ]);
            }

            if ($items === []) {
                throw ValidationException::withMessages([
                    'segments' => 'Добавьте хотя бы один отрезок.',
                ]);
            }

            $normalizedItems = [];
            $totalMm = '0';
            $locationIds = [];

            foreach ($items as $index => $item) {
                $lengthMm = $this->normalizeLengthMm(
                    $item['length_mm'] ?? null,
                    "segments.{$index}.length_mm",
                );

                $locationId = (int) ($item['location_id'] ?? 0);

                if ($locationId <= 0) {
                    throw ValidationException::withMessages([
                        "segments.{$index}.location_id" => 'Выберите ячейку хранения.',
                    ]);
                }

                $normalizedItems[] = [
                    'location_id' => $locationId,
                    'length_mm' => $lengthMm,
                ];

                $totalMm = bcadd($totalMm, $lengthMm, 3);
                $locationIds[$locationId] = true;
            }

            $locations = Location::query()
                ->whereIn('id', array_keys($locationIds))
                ->lockForUpdate()
                ->get()
                ->keyBy('id');

            foreach (array_keys($locationIds) as $locationId) {
                if (! $locations->has($locationId)) {
                    throw ValidationException::withMessages([
                        'location_id' => 'Одна из выбранных ячеек не существует.',
                    ]);
                }
            }

            $totalQuantity = bcdiv($totalMm, '1000', 3);

            $movement = StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => null,
                'to_location_id' => count($locationIds) === 1
                    ? (int) array_key_first($locationIds)
                    : null,
                'quantity' => $totalQuantity,
                'type' => StockMovementType::RECEIPT,
                'comment' => $comment,
                'user_id' => $userId,
            ]);

            $affectedLocations = [];

            foreach ($normalizedItems as $item) {
                $segment = ProductSegment::query()->create([
                    'product_id' => $product->id,
                    'location_id' => $item['location_id'],
                    'length_mm' => $item['length_mm'],
                    'status' => ProductSegmentStatus::AVAILABLE,
                    'stock_movement_id' => $movement->id,
                ]);

                SegmentMovement::query()->create([
                    'product_segment_id' => $segment->id,
                    'product_id' => $product->id,
                    'type' => SegmentMovementType::RECEIPT,
                    'from_location_id' => null,
                    'to_location_id' => $item['location_id'],
                    'length_mm' => $item['length_mm'],
                    'stock_movement_id' => $movement->id,
                    'comment' => $comment,
                    'user_id' => $userId,
                ]);

                $affectedLocations[$item['location_id']] = true;
            }

            foreach (array_keys($affectedLocations) as $locationId) {
                $this->syncLocationStock($product->id, (int) $locationId);
            }

            return $movement;
        }, attempts: 3);
    }

    /**
     * Перемещение выбранных физических отрезков в другую ячейку.
     * Отрезки перемещаются целиком, частичного перемещения нет.
     *
     * @param  list<int>  $segmentIds
     * @return list<StockMovement> По одному движению на каждую исходную ячейку
     */
    public function transferSegments(
        int $productId,
        array $segmentIds,
        int $toLocationId,
        ?string $comment,
        ?int $userId,
    ): array {
        return DB::transaction(function () use (
            $productId,
            $segmentIds,
            $toLocationId,
            $comment,
            $userId,
        ): array {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $product->usesLengthStock()) {
                throw ValidationException::withMessages([
                    'product_id' => 'Товар не использует учёт по отрезкам.',
                ]);
            }

            $segmentIds = array_values(array_unique(array_map('intval', $segmentIds)));

            if ($segmentIds === []) {
                throw ValidationException::withMessages([
                    'segment_ids' => 'Выберите хотя бы один отрезок.',
                ]);
            }

            $destination = Location::query()
                ->whereKey($toLocationId)
                ->lockForUpdate()
                ->first();

            if ($destination === null) {
                throw ValidationException::withMessages([
                    'to_location_id' => 'Целевая ячейка не существует.',
                ]);
            }

            $segments = ProductSegment::query()
                ->where('product_id', $product->id)
                ->whereIn('id', $segmentIds)
                ->lockForUpdate()
                ->get();

            if ($segments->count() !== count($segmentIds)) {
                throw ValidationException::withMessages([
                    'segment_ids' => 'Часть выбранных отрезков не найдена.',
                ]);
            }

            $unavailable = $segments->first(
                fn (ProductSegment $segment) => $segment->status !== ProductSegmentStatus::AVAILABLE,
            );

            if ($unavailable !== null) {
                throw ValidationException::withMessages([
                    'segment_ids' => "Отрезок #{$unavailable->id} недоступен для перемещения (статус: {$unavailable->status->label()}).",
                ]);
            }

            $segmentsByLocation = $segments->groupBy('location_id');

            if ($segmentsByLocation->has($toLocationId) && $segmentsByLocation->count() === 1) {
                throw ValidationException::withMessages([
                    'to_location_id' => 'Отрезки уже находятся в выбранной ячейке.',
                ]);
            }

            $movements = [];
            $affectedLocations = [$toLocationId => true];

            foreach ($segmentsByLocation as $fromLocationId => $locationSegments) {
                $fromLocationId = (int) $fromLocationId;

                if ($fromLocationId === $toLocationId) {
                    continue;
                }

                $totalMm = '0';

                foreach ($locationSegments as $segment) {
                    $totalMm = bcadd($totalMm, (string) $segment->length_mm, 3);
                }

                $movement = StockMovement::query()->create([
                    'product_id' => $product->id,
                    'from_location_id' => $fromLocationId,
                    'to_location_id' => $toLocationId,
                    'quantity' => bcdiv($totalMm, '1000', 3),
                    'type' => StockMovementType::TRANSFER,
                    'comment' => $comment,
                    'user_id' => $userId,
                ]);

                $movements[] = $movement;

                foreach ($locationSegments as $segment) {
                    $segment->update(['location_id' => $toLocationId]);

                    SegmentMovement::query()->create([
                        'product_segment_id' => $segment->id,
                        'product_id' => $product->id,
                        'type' => SegmentMovementType::TRANSFER,
                        'from_location_id' => $fromLocationId,
                        'to_location_id' => $toLocationId,
                        'length_mm' => $segment->length_mm,
                        'stock_movement_id' => $movement->id,
                        'comment' => $comment,
                        'user_id' => $userId,
                    ]);
                }

                $affectedLocations[$fromLocationId] = true;
            }

            foreach (array_keys($affectedLocations) as $locationId) {
                $this->syncLocationStock($product->id, (int) $locationId);
            }

            return $movements;
        }, attempts: 3);
    }

    /**
     * Подбор отрезка по алгоритму best-fit:
     * 1. Только доступные отрезки достаточной длины.
     * 2. Приоритет — вариант, дающий полезный остаток (>= min_remainder_mm),
     *    перед вариантом, где остаток уйдёт в отход.
     * 3. Среди равных — наименьший достаточный отрезок, при равенстве — FIFO.
     *
     * Для товаров без резки (allow_cutting = false) требуется точное
     * совпадение длины — продаются только целые отрезки.
     *
     * @param  string  $lengthMm  Требуемая длина в мм (без учёта ширины реза)
     */
    public function findBestFitSegment(
        int $productId,
        string $lengthMm,
        ?int $locationId = null,
        bool $forUpdate = false,
    ): ?ProductSegment {
        $product = Product::query()->findOrFail($productId);

        if (! $product->usesLengthStock()) {
            return null;
        }

        $requiredMm = bcadd($lengthMm, '0', 3);

        if (bccomp($requiredMm, '0', 3) <= 0) {
            return null;
        }

        $minSaleMm = $product->min_sale_length_mm !== null
            ? (string) $product->min_sale_length_mm
            : null;

        if ($minSaleMm !== null && bccomp($requiredMm, $minSaleMm, 3) < 0) {
            return null;
        }

        if (! $product->allow_cutting) {
            $segment = ProductSegment::query()
                ->where('product_id', $productId)
                ->where('status', ProductSegmentStatus::AVAILABLE)
                ->where('length_mm', $requiredMm)
                ->when($locationId !== null, fn ($q) => $q->where('location_id', $locationId))
                ->when($forUpdate, fn ($q) => $q->lockForUpdate())
                ->orderBy('created_at')
                ->orderBy('id')
                ->first();

            return $segment;
        }

        $cutWidthMm = (string) ($product->cut_width_mm ?? '0');
        $minRemainderMm = (string) ($product->min_remainder_mm ?? '0');
        $minNeededMm = bcadd($requiredMm, $cutWidthMm, 3);

        $query = ProductSegment::query()
            ->where('product_id', $productId)
            ->where('status', ProductSegmentStatus::AVAILABLE)
            ->where('length_mm', '>=', $minNeededMm)
            ->when($locationId !== null, fn ($q) => $q->where('location_id', $locationId))
            ->orderBy('length_mm')
            ->orderBy('created_at')
            ->orderBy('id');

        if ($forUpdate) {
            $query->lockForUpdate();
        }

        $firstCandidate = null;

        foreach ($query->get() as $segment) {
            $remainderRaw = bcsub((string) $segment->length_mm, $minNeededMm, 3);

            if ($firstCandidate === null) {
                $firstCandidate = $segment;
            }

            $hasUsableRemainder = bccomp($remainderRaw, '0', 3) > 0
                && bccomp($remainderRaw, $minRemainderMm, 3) >= 0;

            if ($hasUsableRemainder) {
                return $segment;
            }
        }

        return $firstCandidate;
    }

    /**
     * Резервирует конкретные отрезки под позиции заказа (вызывается при
     * создании заказа). Если подходящего отрезка нет — позиция остаётся
     * без резерва (backorder), резка подберёт отрезок при комплектации.
     */
    public function reserveForOrder(Order $order, ?int $userId): void
    {
        DB::transaction(function () use ($order, $userId): void {
            foreach ($order->items()->with('product')->get() as $item) {
                $product = $item->product;

                if (! $product instanceof Product || ! $product->usesLengthStock()) {
                    continue;
                }

                // Позиция «N кусков по length_mm»: резервируем под каждый кусок
                if ($item->length_mm !== null) {
                    $pieces = max(1, (int) round((float) $item->quantity));

                    for ($i = 0; $i < $pieces; $i++) {
                        $segment = $this->findBestFitSegment($product->id, (string) $item->length_mm, null, true);

                        if ($segment === null) {
                            continue;
                        }

                        $segment->update([
                            'status' => ProductSegmentStatus::RESERVED,
                            'order_item_id' => $item->id,
                        ]);

                        SegmentMovement::query()->create([
                            'product_segment_id' => $segment->id,
                            'product_id' => $product->id,
                            'type' => SegmentMovementType::RESERVE,
                            'length_mm' => $segment->length_mm,
                            'stock_movement_id' => null,
                            'order_item_id' => $item->id,
                            'comment' => "Резерв под заказ {$order->order_number}",
                            'user_id' => $userId,
                        ]);
                    }

                    continue;
                }

                $requiredMm = bcmul((string) $item->quantity, '1000', 3);

                $segment = $this->findBestFitSegment($product->id, $requiredMm, null, true);

                if ($segment === null) {
                    continue;
                }

                $segment->update([
                    'status' => ProductSegmentStatus::RESERVED,
                    'order_item_id' => $item->id,
                ]);

                SegmentMovement::query()->create([
                    'product_segment_id' => $segment->id,
                    'product_id' => $product->id,
                    'type' => SegmentMovementType::RESERVE,
                    'length_mm' => $segment->length_mm,
                    'stock_movement_id' => null,
                    'order_item_id' => $item->id,
                    'comment' => "Резерв под заказ {$order->order_number}",
                    'user_id' => $userId,
                ]);
            }
        }, attempts: 3);
    }

    /**
     * Снимает резервы отрезков при отмене заказа.
     */
    public function releaseForOrder(Order $order, ?int $userId): void
    {
        DB::transaction(function () use ($order, $userId): void {
            $itemIds = $order->items()->pluck('id');

            if ($itemIds->isEmpty()) {
                return;
            }

            $segments = ProductSegment::query()
                ->whereIn('order_item_id', $itemIds)
                ->where('status', ProductSegmentStatus::RESERVED)
                ->lockForUpdate()
                ->get();

            foreach ($segments as $segment) {
                $orderItemId = $segment->order_item_id;

                $segment->update([
                    'status' => ProductSegmentStatus::AVAILABLE,
                    'order_item_id' => null,
                ]);

                SegmentMovement::query()->create([
                    'product_segment_id' => $segment->id,
                    'product_id' => $segment->product_id,
                    'type' => SegmentMovementType::RELEASE,
                    'length_mm' => $segment->length_mm,
                    'order_item_id' => $orderItemId,
                    'comment' => "Снятие резерва по заказу {$order->order_number}",
                    'user_id' => $userId,
                ]);
            }
        }, attempts: 3);
    }

    /**
     * Выполняет резку под позиции заказа с товарами stock_mode = length.
     * Вызывается при переводе заказа в статус «Комплектуется».
     */
    public function cutForOrder(Order $order, ?int $userId, ?string $cutWidthOverrideMm = null): void
    {
        DB::transaction(function () use ($order, $userId, $cutWidthOverrideMm): void {
            foreach ($order->items()->with('product')->get() as $item) {
                $product = $item->product;

                if (! $product instanceof Product || ! $product->usesLengthStock()) {
                    continue;
                }

                // Позиция «N кусков по length_mm»: режем каждый кусок отдельно
                if ($item->length_mm !== null) {
                    $pieces = max(1, (int) round((float) $item->quantity));

                    for ($i = 0; $i < $pieces; $i++) {
                        $this->cutOrderItem($item, $product, $order, $userId, (string) $item->length_mm, $cutWidthOverrideMm);
                    }

                    continue;
                }

                $this->cutOrderItem($item, $product, $order, $userId, null, $cutWidthOverrideMm);
            }
        }, attempts: 3);
    }

    /**
     * Режет один отрезок под позицию заказа: проданная часть списывается,
     * остаток создаётся новым отрезком с parent_segment_id, отход —
     * в scrap. Фактическая ширина реза берётся из настроек товара.
     */
    private function cutOrderItem(
        OrderItem $item,
        Product $product,
        Order $order,
        ?int $userId,
        ?string $pieceLengthMm = null,
        ?string $cutWidthOverrideMm = null,
    ): void {
        // Для позиций «N кусков» длина куска задана явно;
        // иначе — всё количество в метрах как одна длина
        $requiredMm = $pieceLengthMm ?? bcmul((string) $item->quantity, '1000', 3);

        $minSaleMm = $product->min_sale_length_mm !== null
            ? (string) $product->min_sale_length_mm
            : null;

        if ($minSaleMm !== null && bccomp($requiredMm, $minSaleMm, 3) < 0) {
            throw ValidationException::withMessages([
                'order' => "Позиция «{$item->product_name}»: длина меньше минимальной длины продажи.",
            ]);
        }

        $segment = ProductSegment::query()
            ->where('order_item_id', $item->id)
            ->where('status', ProductSegmentStatus::RESERVED)
            ->lockForUpdate()
            ->first();

        if ($segment === null) {
            $segment = $this->findBestFitSegment($product->id, $requiredMm, null, true);
        }

        if ($segment === null) {
            throw ValidationException::withMessages([
                'order' => "По заказу {$order->order_number} недостаточно отрезков для позиции «{$item->product_name}».",
            ]);
        }

        $allowCutting = (bool) $product->allow_cutting;
        // Фактическая ширина реза: переопределение со склада при
        // комплектации имеет приоритет над настройкой товара
        $cutWidthMm = $cutWidthOverrideMm ?? ($allowCutting ? (string) ($product->cut_width_mm ?? '0') : '0');
        $remainderMm = '0';
        $wasteMm = '0';

        if (! $allowCutting) {
            if (bccomp((string) $segment->length_mm, $requiredMm, 3) !== 0) {
                throw ValidationException::withMessages([
                    'order' => "Позиция «{$item->product_name}»: у товара отключена резка, а длина отрезка #{$segment->id} не совпадает с заказанной.",
                ]);
            }
        } else {
            $minNeededMm = bcadd($requiredMm, $cutWidthMm, 3);

            if (bccomp((string) $segment->length_mm, $minNeededMm, 3) < 0) {
                throw ValidationException::withMessages([
                    'order' => "Позиция «{$item->product_name}»: отрезок #{$segment->id} короче заказанной длины с учётом реза.",
                ]);
            }

            $minRemainderMm = (string) ($product->min_remainder_mm ?? '0');
            $remainderRaw = bcsub((string) $segment->length_mm, $minNeededMm, 3);

            $remainderMm = bccomp($remainderRaw, $minRemainderMm, 3) >= 0
                ? $remainderRaw
                : '0';

            $wasteMm = bcsub(
                (string) $segment->length_mm,
                bcadd($requiredMm, $remainderMm, 3),
                3,
            );
        }

        $soldQuantity = bcdiv($requiredMm, '1000', 3);
        $comment = "Заказ {$order->order_number}";

        $saleMovement = StockMovement::query()->create([
            'product_id' => $product->id,
            'from_location_id' => $segment->location_id,
            'to_location_id' => null,
            'quantity' => $soldQuantity,
            'type' => StockMovementType::SALE,
            'comment' => $comment,
            'user_id' => $userId,
        ]);

        $wasteMovement = null;

        if (bccomp($wasteMm, '0', 3) > 0) {
            $wasteMovement = StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => $segment->location_id,
                'to_location_id' => null,
                'quantity' => bcdiv($wasteMm, '1000', 3),
                'type' => StockMovementType::WRITE_OFF,
                'comment' => "Отход при резке. {$comment}",
                'user_id' => $userId,
            ]);
        }

        $segment->update(['status' => ProductSegmentStatus::CONSUMED]);

        $remainder = null;

        if (bccomp($remainderMm, '0', 3) > 0) {
            $remainder = ProductSegment::query()->create([
                'product_id' => $product->id,
                'location_id' => $segment->location_id,
                'parent_segment_id' => $segment->id,
                'length_mm' => $remainderMm,
                'status' => ProductSegmentStatus::AVAILABLE,
                'stock_movement_id' => $saleMovement->id,
            ]);
        }

        SegmentMovement::query()->create([
            'product_segment_id' => $segment->id,
            'product_id' => $product->id,
            'type' => SegmentMovementType::CONSUME,
            'length_mm' => $requiredMm,
            'stock_movement_id' => $saleMovement->id,
            'order_item_id' => $item->id,
            'comment' => $comment,
            'user_id' => $userId,
        ]);

        if ($wasteMovement !== null) {
            SegmentMovement::query()->create([
                'product_segment_id' => $segment->id,
                'product_id' => $product->id,
                'type' => SegmentMovementType::SCRAP,
                'length_mm' => $wasteMm,
                'stock_movement_id' => $wasteMovement->id,
                'order_item_id' => $item->id,
                'comment' => "Отход при резке ({$cutWidthMm} мм пропил). {$comment}",
                'user_id' => $userId,
            ]);
        }

        if ($remainder !== null) {
            SegmentMovement::query()->create([
                'product_segment_id' => $remainder->id,
                'product_id' => $product->id,
                'type' => SegmentMovementType::SPLIT,
                'from_location_id' => $segment->location_id,
                'to_location_id' => $segment->location_id,
                'length_mm' => $remainderMm,
                'stock_movement_id' => $saleMovement->id,
                'order_item_id' => $item->id,
                'comment' => "Остаток отрезка #{$segment->id}. {$comment}",
                'user_id' => $userId,
            ]);
        }

        $this->syncLocationStock($product->id, $segment->location_id);
    }

    /**
     * Возврат товара с учётом по отрезкам: создаёт новый физический
     * отрезок измеренной длины (как при поступлении).
     *
     * @param  string  $quantity  Количество в единицах товара (метры)
     */
    public function returnSingle(
        int $productId,
        int $locationId,
        string $quantity,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        $lengthMm = bcmul($quantity, '1000', 3);

        return $this->receiptSegments(
            $productId,
            [
                ['location_id' => $locationId, 'length_mm' => $lengthMm],
            ],
            $comment,
            $userId,
        );
    }

    /**
     * Списание выбранных физических отрезков (статус scrapped).
     *
     * @param  list<int>  $segmentIds
     * @return list<StockMovement> По одному движению на каждую исходную ячейку
     */
    public function writeOffSegments(
        int $productId,
        array $segmentIds,
        ?string $comment,
        ?int $userId,
    ): array {
        return DB::transaction(function () use (
            $productId,
            $segmentIds,
            $comment,
            $userId,
        ): array {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $product->usesLengthStock()) {
                throw ValidationException::withMessages([
                    'product_id' => 'Товар не использует учёт по отрезкам.',
                ]);
            }

            $segmentIds = array_values(array_unique(array_map('intval', $segmentIds)));

            if ($segmentIds === []) {
                throw ValidationException::withMessages([
                    'segment_ids' => 'Выберите хотя бы один отрезок.',
                ]);
            }

            $segments = ProductSegment::query()
                ->where('product_id', $product->id)
                ->whereIn('id', $segmentIds)
                ->lockForUpdate()
                ->get();

            if ($segments->count() !== count($segmentIds)) {
                throw ValidationException::withMessages([
                    'segment_ids' => 'Часть выбранных отрезков не найдена.',
                ]);
            }

            $blocked = $segments->first(
                fn (ProductSegment $segment) => $segment->status === ProductSegmentStatus::RESERVED,
            );

            if ($blocked !== null) {
                throw ValidationException::withMessages([
                    'segment_ids' => "Отрезок #{$blocked->id} зарезервирован под заказ и не может быть списан.",
                ]);
            }

            $segmentsByLocation = $segments->groupBy('location_id');
            $movements = [];
            $affectedLocations = [];

            foreach ($segmentsByLocation as $locationId => $locationSegments) {
                $locationId = (int) $locationId;
                $totalMm = '0';

                foreach ($locationSegments as $segment) {
                    $totalMm = bcadd($totalMm, (string) $segment->length_mm, 3);
                }

                $movement = StockMovement::query()->create([
                    'product_id' => $product->id,
                    'from_location_id' => $locationId,
                    'to_location_id' => null,
                    'quantity' => bcdiv($totalMm, '1000', 3),
                    'type' => StockMovementType::WRITE_OFF,
                    'comment' => $comment,
                    'user_id' => $userId,
                ]);

                $movements[] = $movement;

                foreach ($locationSegments as $segment) {
                    $segment->update(['status' => ProductSegmentStatus::SCRAPPED]);

                    SegmentMovement::query()->create([
                        'product_segment_id' => $segment->id,
                        'product_id' => $product->id,
                        'type' => SegmentMovementType::WRITE_OFF,
                        'from_location_id' => $locationId,
                        'to_location_id' => null,
                        'length_mm' => $segment->length_mm,
                        'stock_movement_id' => $movement->id,
                        'comment' => $comment,
                        'user_id' => $userId,
                    ]);
                }

                $affectedLocations[$locationId] = true;
            }

            foreach (array_keys($affectedLocations) as $locationId) {
                $this->syncLocationStock($product->id, (int) $locationId);
            }

            return $movements;
        }, attempts: 3);
    }

    /**
     * Инвентаризационная корректировка длины существующего отрезка.
     * Физическая длина куска может отличаться от учётной (обмер,
     * обрезка вне системы) — фиксируем разницу движением INVENTORY.
     */
    public function correctSegmentLength(
        int $productId,
        int $segmentId,
        string $newLengthMm,
        ?string $comment,
        ?int $userId,
    ): StockMovement {
        return DB::transaction(function () use (
            $productId,
            $segmentId,
            $newLengthMm,
            $comment,
            $userId,
        ): StockMovement {
            $product = Product::query()
                ->whereKey($productId)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $product->usesLengthStock()) {
                throw ValidationException::withMessages([
                    'product_id' => 'Товар не использует учёт по отрезкам.',
                ]);
            }

            $newLengthMm = $this->normalizeLengthMm($newLengthMm, 'length_mm');

            $segment = ProductSegment::query()
                ->where('product_id', $product->id)
                ->whereKey($segmentId)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $segment->status->countsInStock()) {
                throw ValidationException::withMessages([
                    'segment_id' => "Отрезок #{$segment->id} в статусе «{$segment->status->label()}» не может быть скорректирован.",
                ]);
            }

            $oldLengthMm = (string) $segment->length_mm;
            $diffMm = bcsub($newLengthMm, $oldLengthMm, 3);

            if (bccomp($diffMm, '0', 3) === 0) {
                throw ValidationException::withMessages([
                    'length_mm' => 'Новая длина совпадает с текущей.',
                ]);
            }

            $diffQuantity = bcdiv($diffMm, '1000', 3);
            $absQuantity = bccomp($diffQuantity, '0', 3) < 0
                ? bcmul($diffQuantity, '-1', 3)
                : $diffQuantity;

            $movement = StockMovement::query()->create([
                'product_id' => $product->id,
                'from_location_id' => bccomp($diffMm, '0', 3) < 0 ? $segment->location_id : null,
                'to_location_id' => bccomp($diffMm, '0', 3) > 0 ? $segment->location_id : null,
                'quantity' => $absQuantity,
                'type' => StockMovementType::INVENTORY,
                'comment' => $comment,
                'user_id' => $userId,
            ]);

            $segment->update(['length_mm' => $newLengthMm]);

            SegmentMovement::query()->create([
                'product_segment_id' => $segment->id,
                'product_id' => $product->id,
                'type' => SegmentMovementType::INVENTORY,
                'from_location_id' => $segment->location_id,
                'to_location_id' => $segment->location_id,
                'length_mm' => ltrim($diffMm, '-'),
                'stock_movement_id' => $movement->id,
                'comment' => $comment,
                'user_id' => $userId,
            ]);

            $this->syncLocationStock($product->id, $segment->location_id);

            return $movement;
        }, attempts: 3);
    }

    /**
     * Пересчитывает агрегированный остаток product_location по физическим
     * отрезкам: суммируются длины отрезков в статусах, учитываемых в запасе,
     * и переводятся в единицы товара (метры).
     */
    public function syncLocationStock(int $productId, int $locationId): void
    {
        $statuses = array_map(
            fn (ProductSegmentStatus $status) => $status->value,
            ProductSegmentStatus::stockCounting(),
        );

        $totalMm = DB::table('product_segments')
            ->where('product_id', $productId)
            ->where('location_id', $locationId)
            ->whereIn('status', $statuses)
            ->selectRaw('COALESCE(SUM(length_mm), 0) as total')
            ->value('total');

        $quantity = bcdiv((string) $totalMm, '1000', 3);
        $now = now();

        $stock = DB::table('product_location')
            ->where('product_id', $productId)
            ->where('location_id', $locationId)
            ->lockForUpdate()
            ->first();

        if (bccomp($quantity, '0', 3) === 0) {
            if ($stock !== null) {
                DB::table('product_location')
                    ->where('product_id', $productId)
                    ->where('location_id', $locationId)
                    ->delete();
            }

            return;
        }

        if ($stock === null) {
            DB::table('product_location')->insert([
                'product_id' => $productId,
                'location_id' => $locationId,
                'quantity' => $quantity,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            return;
        }

        DB::table('product_location')
            ->where('product_id', $productId)
            ->where('location_id', $locationId)
            ->update([
                'quantity' => $quantity,
                'updated_at' => $now,
            ]);
    }

    private function normalizeLengthMm(
        mixed $value,
        string $field,
    ): string {
        $length = trim((string) $value);

        if (! preg_match('/^\d+(?:\.\d{1,3})?$/', $length)) {
            throw ValidationException::withMessages([
                $field => 'Введите корректную длину отрезка (максимум 3 знака после запятой, в мм).',
            ]);
        }

        if (bccomp($length, '0', 3) <= 0) {
            throw ValidationException::withMessages([
                $field => 'Длина отрезка должна быть больше нуля.',
            ]);
        }

        if (bccomp($length, self::MAX_LENGTH_MM, 3) > 0) {
            throw ValidationException::withMessages([
                $field => 'Длина отрезка превышает максимально допустимое значение.',
            ]);
        }

        return bcadd($length, '0', 3);
    }
}
