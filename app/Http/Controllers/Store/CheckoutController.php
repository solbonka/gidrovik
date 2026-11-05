<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class CheckoutController extends Controller
{
    public function create(): InertiaResponse
    {
        $cart = $this->getCart();
        $items = $cart->load('items.product');

        $cartItems = $items->items->map(function ($item) {
            $product = $item->product;

            return [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'name' => $product->name,
                'code' => $product->code,
                'article' => $product->article,
                'quantity' => (float) $item->quantity,
                'price' => $product->retail_price ?? '0',
                'subtotal' => bcmul((string) $product->retail_price, (string) $item->quantity, 2),
            ];
        });

        $total = $cartItems->sum('subtotal');

        return Inertia::render('store/checkout/Create', [
            'items' => $cartItems,
            'total' => number_format($total, 2, '.', ''),
            'empty' => $cartItems->isEmpty(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $cart = $this->getCart();

        // Validate form
        $validated = $request->validate([
            'customer_name' => 'required|string|max:255',
            'customer_email' => 'required|email|max:255',
            'customer_phone' => 'required|string|max:50',
            'customer_organization' => 'nullable|string|max:255',
            'delivery_method' => 'required|in:delivery,pickup',
            'delivery_address' => 'required_if:delivery_method,delivery|string|max:1000',
            'comment' => 'nullable|string|max:2000',
            'agree_terms' => 'required|boolean',
        ]);

        // Check items still exist and are available
        $itemsData = [];
        $totalAmount = '0';

        foreach ($cart->items()->with('product')->get() as $item) {
            $product = $item->product;

            abort_unless($product->is_active && $product->published, 404, 'Товар больше не доступен');

            $price = $product->retail_price ?? '0';
            $subtotal = bcmul((string) $price, (string) $item->quantity, 2);
            $totalAmount = bcadd($totalAmount, $subtotal, 2);

            $itemsData[] = [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'product_code' => $product->code,
                'article' => $product->article,
                'price' => $price,
                'quantity' => $item->quantity,
                'subtotal' => $subtotal,
            ];
        }

        abort_if(empty($itemsData), 400, 'Корзина пуста');

        DB::beginTransaction();

        try {
            // Create order
            $order = \App\Models\Order::create([
                'customer_name' => $validated['customer_name'],
                'customer_email' => $validated['customer_email'],
                'customer_phone' => $validated['customer_phone'],
                'customer_organization' => $validated['customer_organization'] ?? null,
                'delivery_method' => $validated['delivery_method'],
                'delivery_address' => $validated['delivery_method'] === 'delivery' ? ($validated['delivery_address'] ?? null) : null,
                'comment' => $validated['comment'] ?? null,
                'total_amount' => $totalAmount,
                'status' => \App\Enums\OrderStatus::New,
                'user_id' => Auth::id(),
            ]);

            // Create order items
            foreach ($itemsData as $itemData) {
                $order->items()->create($itemData);
            }

            // Record status history
            $order->statusHistory()->create([
                'from_status' => null,
                'to_status' => \App\Enums\OrderStatus::New,
                'note' => 'Заказ оформлен',
                'changed_by' => Auth::id(),
            ]);

            // Merge guest cart into user cart if applicable
            if (Auth::check() && session('guest_cart_id')) {
                $guestCart = Cart::find(session('guest_cart_id'));
                if ($guestCart) {
                    $userCart = $this->getCart();
                    $guestCart->mergeInto($userCart);
                    $guestCart->delete();
                    session()->forget('guest_cart_id');
                }
            }

            // Clear cart
            $cart->items()->delete();

            DB::commit();

            // Send confirmation email (async)
            \App\Queue\Jobs\SendOrderConfirmationEmail::dispatch($order);

            // Store access token in session for non-auth users (expires after 30 min)
            if (!Auth::check()) {
                session(['order_access_token_' . $order->order_number => $order->access_token]);
                session(['order_access_time_' . $order->order_number => now()]);
            }

            return redirect()->route('store.checkout.success', $order->order_number);
        } catch (\Throwable $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function success(string $orderNumber, \Illuminate\Http\Request $request): \Inertia\Response
    {
        // For authenticated users, check if order belongs to them
        if (Auth::check()) {
            $order = \App\Models\Order::query()
                ->with(['items'])
                ->where('order_number', $orderNumber)
                ->where('user_id', Auth::id())
                ->firstOrFail();
        } else {
            // For guest users, check session token with 30 min expiry
            $sessionToken = session('order_access_token_' . $orderNumber);
            $sessionTime = session('order_access_time_' . $orderNumber);

            if (!$sessionToken || !$sessionTime || $sessionTime->diffInMinutes(now()) > 30) {
                abort(403, 'Срок доступа к заказу истёк. Войдите в аккаунт или свяжитесь с менеджером.');
            }

            $order = \App\Models\Order::query()
                ->with(['items'])
                ->where('order_number', $orderNumber)
                ->where('access_token', $sessionToken)
                ->firstOrFail();
        }

        return inertia('store/checkout/Success', [
            'order' => [
                'id' => $order->id,
                'order_number' => $order->order_number,
                'customer_name' => $order->customer_name,
                'customer_email' => $order->customer_email,
                'customer_phone' => $order->customer_phone,
                'delivery_method' => $order->delivery_method,
                'delivery_method_label' => $order->delivery_method === 'delivery' ? 'Доставка' : 'Самовывоз',
                'delivery_address' => $order->delivery_address,
                'total_amount' => number_format((float) $order->total_amount, 2, '.', ''),
                'status' => $order->status->value,
                'status_label' => $order->status->label(),
                'status_color' => $order->status->color(),
                'created_at' => $order->created_at->format('d.m.Y H:i'),
                'items' => $order->items->map(fn ($item) => [
                    'name' => $item->product_name,
                    'quantity' => (float) $item->quantity,
                    'price' => number_format((float) $item->price, 2, '.', ''),
                    'subtotal' => number_format((float) ($item->subtotal ?? 0), 2, '.', ''),
                ]),
            ],
        ]);
    }

    protected function getCart(): \App\Models\Cart
    {
        $user = Auth::user();

        if ($user) {
            // Check if there's a guest cart to merge
            if (session('guest_cart_id')) {
                $guestCart = Cart::find(session('guest_cart_id'));
                if ($guestCart && !$guestCart->items->isEmpty()) {
                    $userCart = Cart::firstOrCreate(['user_id' => $user->id], ['session_id' => null]);
                    $guestCart->mergeInto($userCart);
                    $guestCart->delete();
                    session()->forget('guest_cart_id');

                    return $userCart;
                }
            }

            return Cart::firstOrCreate(['user_id' => $user->id], ['session_id' => null]);
        }

        $sessionId = session('cart_session_id') ?? str()->random(40);
        if (!session('cart_session_id')) {
            session(['cart_session_id' => $sessionId]);
        }

        $cart = Cart::firstOrCreate(['session_id' => $sessionId], []);

        // If cart has items and user logs in later, store cart ID for merge
        if (!$cart->items->isEmpty() && Auth::check()) {
            session(['guest_cart_id' => $cart->id]);
        }

        return $cart;
    }
}
