<?php

namespace App\Providers;

use Illuminate\Auth\Events\Login;
use Illuminate\Auth\Events\Registered;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        Login::class => [
            \App\Listeners\LinkGuestOrdersToUser::class,
        ],
        Registered::class => [
            \App\Listeners\LinkGuestOrdersToUser::class,
            \App\Listeners\SendNewUserRegistrationNotification::class,
        ],
    ];

    public function boot(): void
    {
        //
    }
}
