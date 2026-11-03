<?php

namespace App\Notifications;

use App\Mail\PasswordResetMail;
use Illuminate\Auth\Notifications\ResetPassword as BaseResetPassword;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends BaseResetPassword
{
    public function toMail($notifiable)
    {
        return (new PasswordResetMail(
            $this->token,
            $notifiable->getEmailForPasswordReset(),
            $notifiable->name
        ))->to($notifiable->getEmailForPasswordReset());
    }
}
