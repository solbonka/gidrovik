<?php

namespace App\Observers;

use App\Mail\LowStockAlertMail;
use App\Models\Product;
use App\Models\StockMovement;
use Illuminate\Support\Facades\Mail;

class StockMovementObserver
{
    public function created(StockMovement $movement): void
    {
        $product = $movement->product;

        if (!$product) {
            return;
        }

        $totalQuantity = (int) $product->total_quantity;
        $minimumStock = (float) ($product->minimum_stock ?? 0);

        // Check if stock is below minimum
        if ($minimumStock > 0 && $totalQuantity < $minimumStock) {
            $this->sendLowStockAlert($product, $totalQuantity, $minimumStock);
        }
    }

    protected function sendLowStockAlert(Product $product, int $currentQuantity, float $minimumStock): void
    {
        $adminEmail = config('mail.admin_email', config('mail.from.address'));
        if (!$adminEmail) {
            return;
        }

        Mail::to($adminEmail)->send(new LowStockAlertMail([
            [
                'name' => $product->name,
                'code' => $product->code,
                'article' => $product->article,
                'quantity' => (string) $currentQuantity,
                'minimum' => (string) $minimumStock,
            ],
        ]));
    }
}
