<?php

namespace App\Queue\Jobs;

use App\Mail\NewOrderNotificationMail;
use App\Mail\OrderConfirmationMail;
use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendOrderConfirmationEmail implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public Order $order
    ) {}

    public function handle(): void
    {
        // Send confirmation to buyer
        Mail::to($this->order->customer_email)->send(new OrderConfirmationMail($this->order));

        // Send notification to admin
        $adminEmail = config('mail.admin_email', config('mail.from.address'));
        if ($adminEmail) {
            Mail::to($adminEmail)->send(new NewOrderNotificationMail($this->order));
        }
    }
}
