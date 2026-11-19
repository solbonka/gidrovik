<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class CartController extends Controller
{
    protected function getCart(): Cart
    {
        $user = Auth::user();

        if ($user) {
            return Cart::firstOrCreate(['user_id' => $user->id], ['session_id' => null]);
        }

        $sessionId = session()->getId() ?? str()->random(40);
        session(['cart_session_id' => $sessionId]);

        return Cart::firstOrCreate(['session_id' => $sessionId], []);
    }

    public function index(): InertiaResponse
    {
        $cart = $this->getCart();
        $items = $cart->load('items.product');

        $cartItems = $items->items->map(function (CartItem $item) {
            $product = $item->product;

            $isPieceLine = $product->usesLengthStock() && $item->length_mm !== null;
            $lineMeters = $isPieceLine
                ? bcdiv(bcmul((string) $item->length_mm, (string) $item->quantity, 3), '1000', 3)
                : (string) $item->quantity;

            return [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'product_slug' => $product->slug,
                'quantity' => (float) $item->quantity,
                'length_mm' => $item->length_mm !== null ? (float) $item->length_mm : null,
                'length_label' => $item->length_mm !== null
                    ? $item->quantity.' × '.rtrim(rtrim(number_format((float) $item->length_mm / 1000, 3, '.', ''), '0'), '.').' м'
                    : null,
                'name' => $product->name,
                'code' => $product->code,
                'article' => $product->article,
                'price' => $product->retail_price ?? '0',
                'subtotal' => bcmul((string) $product->retail_price, $lineMeters, 2),
                'stock_status' => $product->stock_status,
                'unit' => $product->unit ?? 'шт.',
                'image_path' => $product->images->first()?->getUrlForSize('thumbnail'),
            ];
        });

        $total = $cartItems->sum('subtotal');

        return Inertia::render('store/cart/Index', [
            'items' => $cartItems,
            'total' => number_format($total, 2, '.', ''),
            'item_count' => $items->items->count(),
        ])->with([
            'title' => 'Корзина — Гидровик',
            'robots' => 'noindex, nofollow',
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|numeric|min:0.001',
            'length_mm' => 'nullable|numeric|gt:0|max:999999999.999',
        ]);

        $product = Product::findOrFail($request->product_id);

        abort_unless($product->is_active && $product->published, 404);

        $cart = $this->getCart();
        $quantity = $request->input('quantity', 1);

        // Для товаров с учётом по отрезкам строка = N кусков длиной length_mm.
        // quantity трактуется как количество кусков.
        $lengthMm = null;
        if ($product->usesLengthStock() && $request->filled('length_mm')) {
            $lengthMm = bcadd((string) $request->input('length_mm'), '0', 3);
            $quantity = max(1, (int) round((float) $quantity));
        }

        $existingQuery = $cart->items()
            ->where('product_id', $product->id);

        if ($lengthMm === null) {
            $existingQuery->whereNull('length_mm');
        } else {
            $existingQuery->where('length_mm', $lengthMm);
        }

        $existingItem = $existingQuery->first();

        if ($existingItem) {
            $existingItem->quantity = bcadd(
                (string) $existingItem->quantity,
                (string) $quantity,
                3
            );
            $existingItem->save();
        } else {
            $cart->items()->create([
                'product_id' => $product->id,
                'quantity' => $quantity,
                'length_mm' => $lengthMm,
            ]);
        }

        // Merge guest cart into user cart if user just logged in
        if (Auth::check() && session('guest_cart_id')) {
            $guestCart = Cart::find(session('guest_cart_id'));
            if ($guestCart) {
                $userCart = $this->getCart();
                $guestCart->mergeInto($userCart);
                $guestCart->delete();
                session()->forget('guest_cart_id');
            }
        }

        return redirect()->back();
    }

    public function update(Request $request, int $itemId): RedirectResponse
    {
        $request->validate([
            'quantity' => 'required|numeric|min:0.001',
        ]);

        $cart = $this->getCart();
        $item = $cart->items()->findOrFail($itemId);

        $item->quantity = $request->input('quantity');
        $item->save();

        return redirect()->back();
    }

    public function destroy(Request $request, int $itemId): RedirectResponse
    {
        $cart = $this->getCart();
        $item = $cart->items()->findOrFail($itemId);
        $item->delete();

        return redirect()->back();
    }
}
