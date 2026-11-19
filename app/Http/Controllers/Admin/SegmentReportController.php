<?php

namespace App\Http\Controllers\Admin;

use App\Enums\ProductSegmentStatus;
use App\Enums\StockMode;
use App\Http\Controllers\Controller;
use App\Models\ProductSegment;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response;

class SegmentReportController extends Controller
{
    public function index(): Response
    {
        // Срез по товарам с учётом по отрезкам
        $rows = ProductSegment::query()
            ->join('products', 'products.id', '=', 'product_segments.product_id')
            ->join('locations', 'locations.id', '=', 'product_segments.location_id')
            ->join('racks', 'racks.id', '=', 'locations.rack_id')
            ->where('products.stock_mode', StockMode::LENGTH->value)
            ->groupBy(
                'products.id',
                'products.name',
                'products.code',
                'racks.code',
                'locations.number',
                'product_segments.status',
            )
            ->selectRaw('
                products.id as product_id,
                products.name as product_name,
                products.code as product_code,
                racks.code as rack_code,
                locations.number as location_number,
                product_segments.status,
                COUNT(*) as segments_count,
                SUM(product_segments.length_mm) as total_mm,
                MAX(product_segments.length_mm) as max_mm
            ')
            ->orderBy('products.name')
            ->orderBy('racks.code')
            ->orderBy('locations.number')
            ->orderBy('product_segments.status')
            ->get();

        $byProduct = [];

        foreach ($rows as $row) {
            $key = $row->product_id;
            $byProduct[$key] ??= [
                'product_id' => $row->product_id,
                'name' => $row->product_name,
                'code' => $row->product_code,
                'available_mm' => '0',
                'available_count' => 0,
                'reserved_mm' => '0',
                'reserved_count' => 0,
                'quarantined_mm' => '0',
                'scrapped_mm' => '0',
                'consumed_mm' => '0',
                'locations' => [],
            ];

            $status = ProductSegmentStatus::from($row->status);
            $mm = (string) $row->total_mm;

            if ($status === ProductSegmentStatus::AVAILABLE) {
                $byProduct[$key]['available_mm'] = bcadd($byProduct[$key]['available_mm'], $mm, 3);
                $byProduct[$key]['available_count'] += (int) $row->segments_count;
            } elseif ($status === ProductSegmentStatus::RESERVED) {
                $byProduct[$key]['reserved_mm'] = bcadd($byProduct[$key]['reserved_mm'], $mm, 3);
                $byProduct[$key]['reserved_count'] += (int) $row->segments_count;
            } elseif ($status === ProductSegmentStatus::QUARANTINED) {
                $byProduct[$key]['quarantined_mm'] = bcadd($byProduct[$key]['quarantined_mm'], $mm, 3);
            } elseif ($status === ProductSegmentStatus::SCRAPPED) {
                $byProduct[$key]['scrapped_mm'] = bcadd($byProduct[$key]['scrapped_mm'], $mm, 3);
            } elseif ($status === ProductSegmentStatus::CONSUMED) {
                $byProduct[$key]['consumed_mm'] = bcadd($byProduct[$key]['consumed_mm'], $mm, 3);
            }

            $byProduct[$key]['locations'][] = [
                'location_label' => "{$row->rack_code}-{$row->location_number}",
                'status' => $status->value,
                'status_label' => $status->label(),
                'count' => (int) $row->segments_count,
                'total_mm' => $mm,
                'max_mm' => (string) $row->max_mm,
            ];
        }

        // Отходы за последние 30 дней (scrapped + consumed не восстановить —
        // берём scrapped сегменты по дате создания как приближение)
        $scrapLast30 = DB::table('product_segments')
            ->join('products', 'products.id', '=', 'product_segments.product_id')
            ->where('products.stock_mode', StockMode::LENGTH->value)
            ->where('product_segments.status', ProductSegmentStatus::SCRAPPED->value)
            ->where('product_segments.created_at', '>=', now()->subDays(30))
            ->selectRaw('COALESCE(SUM(product_segments.length_mm), 0) as total_mm')
            ->value('total_mm');

        return Inertia::render('admin/stock/Segments', [
            'products' => array_values($byProduct),
            'scrap_last_30_days_mm' => (string) $scrapLast30,
        ])->with([
            'title' => 'Отчёт по отрезкам — Гидровик',
        ]);
    }
}
