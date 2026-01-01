<?php

use App\Http\Controllers\ExampleController;

// Minimal route file
$router = isset($router) ? $router : null;

// For basic demonstration, respond to / with a simple message.
if (php_sapi_name() !== 'cli') {
    header('Content-Type: text/plain');
    echo "Truth Lens backend placeholder. Install Laravel via Composer for full functionality.\n";
}
