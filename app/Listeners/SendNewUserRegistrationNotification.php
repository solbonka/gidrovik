<?php

namespace App\Listeners;

use App\Queue\Jobs\SendNewUserRegistrationEmail;
use Illuminate\Auth\Events\Registered;

class SendNewUserRegistrationNotification
{
    public function handle(Registered $event): void
    {
        \App\Queue\Jobs\SendNewUserRegistrationEmail::dispatch($event->user);
    }
}
