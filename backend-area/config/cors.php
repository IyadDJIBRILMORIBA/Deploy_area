<?php

return [
    'paths' => [
        'api/*',
        'sanctum/csrf-cookie',
        'auth/*'
    ],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        env('FRONTEND_URL', 'http://localhost:8081'),
        'http://localhost:3000',
        'http://127.0.0.1:8081',
        'http://127.0.0.1:3000'
    ],

    'allowed_origins_patterns' => [],

    'allowed_headers' => [
        'Content-Type',
        'X-Requested-With',
        'Accept',
        'Authorization',
        'Origin'
    ],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,
];
