<?php

namespace App\Http\Controllers\Admin;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderStatusHistory;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class OrderController extends Controller
{
    public function index(Request $request): Response
    {
        $validated = $request->validate([
            'search' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'in:' . implode(',', array_map(fn ($s) => $s->value, OrderStatus::cases()))],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date'],
        ]);

        $search = trim($validated['search'] ?? '');
        $status = $validated['status'] ?? '';
        $dateFrom = $validated['date_from'] ?? null;
        $dateTo = $validated['date_to'] ?? null;

        $query = Order::query()
            ->withCount('items')
            ->with('statusHistory.last');

        if ($search !== '') {
            $query->where(function ($q) use ($search) {
                $q->where('order_number', 'like', "%{$search}%")
                    ->orWhere('customer_name', 'ilike', "%{$search}%")
                    ->orWhere('customer_email', 'ilike', "%{$search}%")
                    ->orWhere('customer_phone', 'like', "%{$search}%");
            });
        }

        if ($status !== '') {
            $query->where('status', $status);
        }

        if ($dateFrom) {
            $query->whereDate('created_at', '>=', $dateFrom);
        }

        if ($dateTo) {
            $query->whereDate('created_at', '<=', $dateTo);
        }

        $orders = $query
            ->latest('id')
            ->paginate(25)
            ->withQueryString()
            ->through(function (Order $order): array {
                $lastStatus = $order->statusHistory->last();

                return [
                    'id' => $order->id,
                    'order_number' => $order->order_number,
                    'customer_name' => $order->customer_name,
                    'customer_email' => $order->customer_email,
                    'customer_phone' => $order->customer_phone,
                    'customer_organization' => $order->customer_organization,
                    'delivery_method' => $order->delivery_method === 'delivery' ? 'Доставка' : 'Самовывоз',
                    'total_amount' => number_format((float) $order->total_amount, 2, '.', ''),
                    'status' => $order->status->value,
                    'status_label' => $order->status->label(),
                    'status_color' => $order->status->color(),
                    'items_count' => $order->items_count,
                    'created_at' => $order->created_at->format('d.m.Y H:i'),
                    'last_status_change' => $lastStatus?->created_at?->format('d.m.Y H:i'),
                ];
            });

        return Inertia::render('admin/orders/Index', [
            'orders' => $orders,
            'filters' => [
                'search' => $search,
                'status' => $status,
                'date_from' => $dateFrom,
                'date_to' => $dateTo,
            ],
            'statuses' => collect(OrderStatus::cases())
                ->map(fn (OrderStatus $status): array => [
                    'value' => $status->value,
                    'label' => $status->label(),
                ])
                ->values(),
        ]);
    }

    public function show(Order $order): Response
    {
        $order->load(['items', 'statusHistory.changedBy']);

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
            'items' => $order->items->map(fn ($item): array => [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'name' => $item->product_name,
                    'code' => $item->product_code ?? null,
                    'article' => $item->article ?? null,
                'quantity' => (float) $item->quantity,
                'price' => number_format((float) $item->price, 2, '.', ''),
                'subtotal' => number_format((float) $item->subtotal, 2, '.', ''),
            ]),
            'status_history' => $order->statusHistory->map(fn ($history): array => [
                'id' => $history->id,
                'from_status' => $history->from_status?->label(),
                'to_status' => $history->to_status->label(),
                'note' => $history->note,
                'changed_by' => $history->changedBy?->name,
                'created_at' => $history->created_at->format('d.m.Y H:i'),
            ]),
        ];

        return Inertia::render('admin/orders/Show', [
            'order' => $orderData,
            'statuses' => collect(OrderStatus::cases())
                ->map(fn (OrderStatus $status): array => [
                    'value' => $status->value,
                    'label' => $status->label(),
                ])
                ->values(),
        ]);
    }

    public function updateStatus(Request $request, Order $order): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'string', 'in:' . implode(',', array_map(fn ($s) => $s->value, OrderStatus::cases()))],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $newStatus = OrderStatus::from($validated['status']);

        // Prevent changing final statuses
        if ($newStatus->isFinal()) {
            return back()->withErrors(['status' => 'Нельзя изменить заказ на финальный статус напрямую.']);
        }

        $oldStatus = $order->status;

        $order->status = $newStatus;
        $order->save();

        $order->statusHistory()->create([
            'from_status' => $oldStatus,
            'to_status' => $newStatus,
            'note' => $validated['note'] ?? null,
            'changed_by' => auth()->id(),
        ]);

        // Send status change notification (async)
        \App\Queue\Jobs\SendOrderStatusChangedEmail::dispatch(
            $order,
            $newStatus->label(),
            $validated['note'] ?? null
        );

        return back()->with('success', 'Статус заказа обновлён.');
    }

    public function markAsCompleted(Order $order): RedirectResponse
    {
        $oldStatus = $order->status;

        $order->status = OrderStatus::Completed;
        $order->save();

        $order->statusHistory()->create([
            'from_status' => $oldStatus,
            'to_status' => OrderStatus::Completed,
            'note' => 'Заказ завершён через админ-панель',
            'changed_by' => auth()->id(),
        ]);

        // Send completion notification (async)
        \App\Queue\Jobs\SendOrderStatusChangedEmail::dispatch(
            $order,
            OrderStatus::Completed->label(),
            'Заказ завершён'
        );

        return back()->with('success', 'Заказ завершён.');
    }

    public function markAsCancelled(Request $request, Order $order): RedirectResponse
    {
        $validated = $request->validate([
            'reason' => ['nullable', 'string', 'max:1000'],
        ]);

        $oldStatus = $order->status;

        $order->status = OrderStatus::Cancelled;
        $order->save();

        $order->statusHistory()->create([
            'from_status' => $oldStatus,
            'to_status' => OrderStatus::Cancelled,
            'note' => $validated['reason'] ?? 'Заказ отменён',
            'changed_by' => auth()->id(),
        ]);

        // Send cancellation notification (async)
        \App\Queue\Jobs\SendOrderStatusChangedEmail::dispatch(
            $order,
            OrderStatus::Cancelled->label(),
            $validated['reason'] ?? 'Заказ отменён'
        );

        return back()->with('success', 'Заказ отменён.');
    }
}
