<?php

namespace Tests\Feature\Admin;

use App\Enums\ProductSegmentStatus;
use App\Enums\StockMode;
use App\Enums\StockMovementType;
use App\Models\Category;
use App\Models\Location;
use App\Models\Product;
use App\Models\ProductSegment;
use App\Models\Rack;
use App\Services\Admin\ProductSegmentService;
use App\Services\Admin\StockMovementService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

class ProductSegmentsTest extends TestCase
{
    use RefreshDatabase;

    private Product $product;

    private Location $locationA;

    private Location $locationB;

    protected function setUp(): void
    {
        parent::setUp();

        $category = Category::query()->create([
            'name' => 'Прутки',
            'slug' => 'prutki',
        ]);

        $rack = Rack::query()->create([
            'code' => 'A1',
            'name' => 'Стеллаж A',
        ]);

        $this->locationA = Location::query()->create([
            'rack_id' => $rack->id,
            'number' => 1,
        ]);

        $this->locationB = Location::query()->create([
            'rack_id' => $rack->id,
            'number' => 2,
        ]);

        $this->product = Product::query()->create([
            'category_id' => $category->id,
            'name' => 'Пруток ZEDEX Ø20',
            'code' => 'ZDX-20',
            'unit' => 'м',
            'stock_mode' => StockMode::LENGTH,
        ]);
    }

    public function test_receipt_segments_creates_segments_movements_and_stock(): void
    {
        $service = app(ProductSegmentService::class);

        $movement = $service->receiptSegments(
            $this->product->id,
            [
                ['location_id' => $this->locationA->id, 'length_mm' => '1000'],
                ['location_id' => $this->locationA->id, 'length_mm' => '750.5'],
                ['location_id' => $this->locationB->id, 'length_mm' => '370'],
            ],
            'Поступление партии',
            null,
        );

        $this->assertSame(StockMovementType::RECEIPT, $movement->type);
        $this->assertSame('2.121', $movement->quantity);

        $this->assertSame(3, ProductSegment::query()->count());
        $this->assertSame(3, DB::table('segment_movements')->count());

        $stockA = DB::table('product_location')
            ->where('product_id', $this->product->id)
            ->where('location_id', $this->locationA->id)
            ->value('quantity');
        $stockB = DB::table('product_location')
            ->where('product_id', $this->product->id)
            ->where('location_id', $this->locationB->id)
            ->value('quantity');

        $this->assertSame('1.751', $stockA);
        $this->assertSame('0.370', $stockB);
    }

    public function test_transfer_segments_moves_only_selected_segments(): void
    {
        $service = app(ProductSegmentService::class);

        $service->receiptSegments(
            $this->product->id,
            [
                ['location_id' => $this->locationA->id, 'length_mm' => '1000'],
                ['location_id' => $this->locationA->id, 'length_mm' => '500'],
            ],
            null,
            null,
        );

        $segment = ProductSegment::query()
            ->where('length_mm', '1000.000')
            ->firstOrFail();

        $movements = $service->transferSegments(
            $this->product->id,
            [$segment->id],
            $this->locationB->id,
            'Перенос на стеллаж B',
            null,
        );

        $this->assertCount(1, $movements);
        $this->assertSame(StockMovementType::TRANSFER, $movements[0]->type);
        $this->assertSame('1.000', $movements[0]->quantity);

        $this->assertSame(
            $this->locationB->id,
            $segment->fresh()->location_id,
        );

        $stockA = DB::table('product_location')
            ->where('product_id', $this->product->id)
            ->where('location_id', $this->locationA->id)
            ->value('quantity');
        $stockB = DB::table('product_location')
            ->where('product_id', $this->product->id)
            ->where('location_id', $this->locationB->id)
            ->value('quantity');

        $this->assertSame('0.500', $stockA);
        $this->assertSame('1.000', $stockB);
    }

    public function test_generic_receipt_creates_single_segment_for_length_product(): void
    {
        $service = app(StockMovementService::class);

        $movement = $service->receipt(
            $this->product->id,
            $this->locationA->id,
            '1.5',
            null,
            null,
        );

        $segment = ProductSegment::query()->sole();

        $this->assertSame('1500.000', (string) $segment->length_mm);
        $this->assertSame($this->locationA->id, $segment->location_id);
        $this->assertSame($movement->id, $segment->stock_movement_id);
        $this->assertSame(ProductSegmentStatus::AVAILABLE, $segment->status);

        $stock = DB::table('product_location')
            ->where('product_id', $this->product->id)
            ->where('location_id', $this->locationA->id)
            ->value('quantity');

        $this->assertSame('1.500', $stock);
    }

    public function test_generic_transfer_is_rejected_for_length_product(): void
    {
        $service = app(StockMovementService::class);

        $service->receipt(
            $this->product->id,
            $this->locationA->id,
            '1',
            null,
            null,
        );

        $this->expectException(ValidationException::class);

        $service->transfer(
            $this->product->id,
            $this->locationA->id,
            $this->locationB->id,
            '1',
            null,
            null,
        );
    }

    public function test_receipt_segments_rejects_non_length_product(): void
    {
        $quantityProduct = Product::query()->create([
            'category_id' => $this->product->category_id,
            'name' => 'Фитинг',
            'code' => 'FIT-1',
            'unit' => 'шт.',
        ]);

        $service = app(ProductSegmentService::class);

        $this->expectException(ValidationException::class);

        $service->receiptSegments(
            $quantityProduct->id,
            [
                ['location_id' => $this->locationA->id, 'length_mm' => '100'],
            ],
            null,
            null,
        );
    }
}
