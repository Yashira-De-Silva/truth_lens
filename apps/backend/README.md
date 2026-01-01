This folder contains a minimal Laravel project skeleton to get started.

Included files:
- composer.json (basic Laravel dependencies)
- artisan (CLI stub)
- public/index.php (front controller)
- app/Http/Controllers/ExampleController.php
- routes/web.php
- .env.example
- .gitignore

Setup
1. Install Composer: https://getcomposer.org/
2. From this `backend` folder run:
   composer install
3. Copy `.env.example` to `.env` and configure database and app settings.
4. Run migrations and start the development server:
   php artisan migrate
   php artisan serve

Notes
- This is a minimal skeleton intended to be replaced by a proper `laravel new` install or `composer create-project` when ready.
