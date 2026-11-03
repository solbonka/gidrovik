<?php

namespace App\Listeners;

use App\Models\Order;
use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Registered;
use Illuminate\Support\Facades\DB;

class LinkGuestOrdersToUser
{
    public function handle(Login|Registered $event): void
    {
        $user = $event->user;

        DB::transaction(function () use ($user) {
            // Find all orders with the same email that don't have a user_id
            $orders = Order::query()
                ->where('customer_email', $user->email)
                ->whereNull('user_id')
                ->get();

            foreach ($orders as $order) {
                $order->update([
                    'user_id' => $user->id,
                ]);

                // Also update status history changed_by if it was null
                $order->statusHistory()
                    ->whereNull('changed_by')
                    ->update(['changed_by' => $user->id]);
            }
        });
    }
}
