<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CorrectProductSegmentRequest;
use App\Http\Requests\Admin\StoreProductSegmentsRequest;
use App\Http\Requests\Admin\TransferProductSegmentsRequest;
use App\Http\Requests\Admin\WriteOffProductSegmentsRequest;
use App\Models\Product;
use App\Services\Admin\ProductSegmentService;
use Illuminate\Http\RedirectResponse;

class ProductSegmentController extends Controller
{
    public function store(
        StoreProductSegmentsRequest $request,
        Product $product,
        ProductSegmentService $productSegmentService,
    ): RedirectResponse {
        $data = $request->validated();

        $items = array_map(
            fn (array $segment): array => [
                'location_id' => (int) $segment['location_id'],
                'length_mm' => (string) $segment['length_mm'],
            ],
            array_values($data['segments']),
        );

        $productSegmentService->receiptSegments(
            productId: $product->id,
            items: $items,
            comment: $data['comment'] ?? null,
            userId: $request->user()?->id,
        );

        return to_route('admin.products.show', $product)
            ->with('success', 'Отрезки успешно оприходованы.');
    }

    public function correct(
        Product $product,
        int $segment,
        CorrectProductSegmentRequest $request,
    ): RedirectResponse {
        $validated = $request->validated();

        $this->segments->correctSegmentLength(
            $product->id,
            $segment,
            (string) $validated['length_mm'],
            $validated['comment'] ?? null,
            $request->user()?->id,
        );

        return back()->with('success', 'Длина отрезка скорректирована.');
    }

    public function writeOff(
        Product $product,
        WriteOffProductSegmentsRequest $request,
    ): RedirectResponse {
        $validated = $request->validated();

        $this->segments->writeOffSegments(
            $product->id,
            array_values($validated['segment_ids']),
            $validated['comment'] ?? null,
            $request->user()?->id,
        );

        return back()->with('success', 'Отрезки списаны.');
    }

    public function transfer(
        TransferProductSegmentsRequest $request,
        Product $product,
        ProductSegmentService $productSegmentService,
    ): RedirectResponse {
        $data = $request->validated();

        $productSegmentService->transferSegments(
            productId: $product->id,
            segmentIds: array_values(array_map('intval', $data['segment_ids'])),
            toLocationId: (int) $data['to_location_id'],
            comment: $data['comment'] ?? null,
            userId: $request->user()?->id,
        );

        return to_route('admin.products.show', $product)
            ->with('success', 'Отрезки успешно перемещены.');
    }
}
