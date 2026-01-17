<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     * For API requests we return null so a 401 JSON is emitted instead of redirect.
     */
    protected function redirectTo(Request $request): ?string
    {
        if ($request->expectsJson()) {
            return null; // Laravel will return 401
        }

        return null; // No named login route; avoid RouteNotFoundException
    }
}
