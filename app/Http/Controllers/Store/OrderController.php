<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class OrderController extends Controller
{
    public function index(): InertiaResponse
    {
        $orders = Auth::user()
            ->orders()
            ->withCount('items')
            ->latest()
            ->paginate(20)
            ->through(function (Order $order) {
                return [
                    'id' => $order->id,
                    'order_number' => $order->order_number,
                    'total_amount' => number_format((float) $order->total_amount, 2, '.', ''),
                    'status' => $order->status->value,
                    'status_label' => $order->status->label(),
                    'status_color' => $order->status->color(),
                    'items_count' => $order->items_count,
                    'created_at' => $order->created_at->format('d.m.Y H:i'),
                    'delivery_method' => $order->delivery_method === 'delivery' ? 'Доставка' : 'Самовывоз',
                ];
            });

        return Inertia::render('store/orders/Index', [
            'orders' => $orders,
        ]);
    }

    public function show(string $orderNumber): InertiaResponse
    {
        $order = Auth::user()
            ->orders()
            ->with(['items.product', 'statusHistory.changedBy'])
            ->where('order_number', $orderNumber)
            ->firstOrFail();

        $orderData = [
            'id' => $order->id,
            'order_number' => $order->order_number,
            'customer_name' => $order->customer_name,
            'customer_email' => $order->customer_email,
            'customer_phone' => $order->customer_phone,
            'customer_organization' => $order->customer_organization,
            'delivery_method' => $order->delivery_method,
            'delivery_method_label' => $order->delivery_method === 'delivery' ? 'Доставка' : 'Самовывоз',
            'delivery_address' => $order->delivery_address,
            'comment' => $order->comment,
            'total_amount' => number_format((float) $order->total_amount, 2, '.', ''),
            'status' => $order->status->value,
            'status_label' => $order->status->label(),
            'status_color' => $order->status->color(),
            'created_at' => $order->created_at->format('d.m.Y H:i'),
            'items' => $order->items->map(fn ($item) => [
                'id' => $item->id,
                'name' => $item->product_name,
                    'code' => $item->product_code ?? null,
                    'article' => $item->article ?? null,
                'quantity' => (float) $item->quantity,
                'price' => number_format((float) $item->price, 2, '.', ''),
                'subtotal' => number_format((float) $item->subtotal, 2, '.', ''),
            ]),
            'status_history' => $order->statusHistory->map(fn ($history) => [
                'id' => $history->id,
                'from_status' => $history->from_status?->label(),
                'to_status' => $history->to_status->label(),
                'note' => $history->note,
                'changed_by' => $history->changedBy?->name,
                'created_at' => $history->created_at->format('d.m.Y H:i'),
            ]),
        ];

        return Inertia::render('store/orders/Show', [
            'order' => $orderData,
        ]);
    }
}
