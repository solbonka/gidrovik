<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ProfileChangedMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $name,
        public array $changes
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Ваш профиль был обновлён - Гидровик РВД',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.profile-changed',
            with: [
                'name' => $this->name,
                'changes' => $this->changes,
            ],
        );
    }
}
