<?php

namespace App\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class NewUserRegistrationMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public User $user
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Новая регистрация пользователя - Гидровик РВД',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.new-user-registration',
            with: [
                'userName' => $this->user->name,
                'userEmail' => $this->user->email,
                'registrationDate' => $this->user->created_at->format('d.m.Y H:i'),
            ],
        );
    }
}
