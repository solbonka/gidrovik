<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class ErrorController extends Controller
{
    public function notFound(): InertiaResponse
    {
        return Inertia::render('errors/NotFound');
    }
}
