<?php

namespace App\Mail;

use App\Models\Product;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class LowStockAlertMail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * @param array<int, array{name: string, code: string, article: string, quantity: string, minimum: string}> $products
     */
    public function __construct(
        public array $products
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Предупреждение о низком остатке товаров - Гидровик РВД',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.low-stock-alert',
        );
    }
}
