<?php

namespace App\Http\Controllers\Store;

use App\Http\Controllers\Controller;

class ErrorController extends Controller
{
    public function notFound(): never
    {
        abort(404);
    }
}
