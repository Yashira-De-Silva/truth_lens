<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

# Truth Lens – Backend API

A Laravel 11 REST API with **JWT authentication** for the Truth Lens Flutter app.

---

## Tech Stack
| Layer | Technology |
|---|---|
| Framework | Laravel 11 |
| Auth | tymon/jwt-auth 2.x |
| Database | MySQL (configurable) |
| PHP | ≥ 8.0 |

---

## Setup

### 1. Install dependencies
```bash
cd apps/backend
composer install
```

### 2. Configure environment
```bash
cp .env.example .env
```
Edit `.env` and set your database credentials:
```ini
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=truth_lens
DB_USERNAME=root
DB_PASSWORD=your_password
```

### 3. Generate keys
```bash
php artisan key:generate
php artisan jwt:secret
```

### 4. Run migrations
```bash
php artisan migrate
```

### 5. Start the development server
```bash
php artisan serve
# API is available at http://localhost:8000/api
```

---

## API Reference

All endpoints return JSON. Protected endpoints require the header:
```
Authorization: Bearer <token>
```

---

### POST `/api/register`
Create a new user account and receive a JWT.

**Request body**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secret123",
  "password_confirmation": "secret123"
}
```

**Success response – 201**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": { "id": 1, "name": "John Doe", "email": "john@example.com" },
    "token": "<jwt>",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

**Validation error – 422**
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": { "email": ["The email has already been taken."] }
}
```

---

### POST `/api/login`
Authenticate and receive a JWT.

**Request body**
```json
{
  "email": "john@example.com",
  "password": "secret123"
}
```

**Success response – 200**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { "id": 1, "name": "John Doe", "email": "john@example.com" },
    "token": "<jwt>",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

**Wrong credentials – 401**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

### POST `/api/logout` 🔒
Invalidate the current token.

**Success response – 200**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### POST `/api/refresh` 🔒
Get a fresh token before the current one expires.

**Success response – 200**
```json
{
  "success": true,
  "token": "<new_jwt>",
  "token_type": "bearer",
  "expires_in": 3600
}
```

---

### GET `/api/me` 🔒
Return the authenticated user's profile.

**Success response – 200**
```json
{
  "success": true,
  "data": { "id": 1, "name": "John Doe", "email": "john@example.com" }
}
```

---

## Flutter Integration

Store the token in `flutter_secure_storage` and attach it to every protected request:

```dart
dio.options.headers['Authorization'] = 'Bearer $token';
```

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework. You can also check out [Laravel Learn](https://laravel.com/learn), where you will be guided through building a modern Laravel application.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
