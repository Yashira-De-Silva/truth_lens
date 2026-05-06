# Truth Lens: AI-Powered News Verification System

## Project Summary
Truth Lens is a cross-platform news verification ecosystem built to help users distinguish between real and misleading information. It combines a Flutter-based mobile interface, a Laravel backend, and a Python machine learning microservice powered by Google Gemini. The system is designed around secure user authentication, live news retrieval, AI-driven fact verification, social interaction, and interactive learning features.

The core verification pipeline is transparent and repeatable: a user claim enters the frontend, the backend routes it to the ML service, the ML service extracts entities, gathers evidence from Wikipedia and The Guardian, synthesizes the result with Gemini, and returns a labeled verdict with confidence and source citations. The architecture is optimized for both accuracy and responsiveness.

This repository contains three core modules:
- `apps/frontend`: Flutter app for iOS, Android, web, and desktop.
- `apps/backend`: Laravel API gateway, user management, social and activity tracking.
- `apps/ml_service`: Flask service for automatic claim verification, live news retrieval, summarization, and AI chat.

---

## Key Capabilities
- Real-time news feed with live articles and verification badges.
- Fact-checking with AI-backed claim verification and evidence sources.
- AI news assistant (`TruthBot`) for conversational explanation and verification.
- Personalized digest and recommended news summaries.
- Article bookmarks, comments, likes, and reading history.
- User profiles, social follow system, and private/public visibility.
- Chat and voice-call support between authenticated users.
- Embedded news-related game experiences: quiz, fact-fiction, and chess.
- Secure authentication using JWT tokens, profile management, and premium subscription flows.
- Deployment-ready architecture using Docker and Render.

---

## Architecture Overview
Truth Lens is implemented in a modular fashion across three services:

1. **Frontend (`apps/frontend`)**
   - Flutter UI with Riverpod state management.
   - Modular feature folders under `apps/frontend/lib/features`.
   - Uses `api_constants.dart` to switch between production and local API endpoints.
   - Navigation includes News, Explore/Search, Digest, Chat, and Profile tabs.

2. **Backend (`apps/backend`)**
   - Laravel 12 API with `tymon/jwt-auth` for JWT authentication.
   - Provides RESTful endpoints for authentication, users, social, news, chat, calls, chess, bookmarks, and comments.
   - Supports MySQL by default, with SQLite available for local development.
   - Includes a production-ready Dockerfile and Render deployment blueprint.

3. **ML Service (`apps/ml_service`)**
   - Flask app running on Python 3.10.
   - Uses Google Gemini via the `google.generativeai` SDK.
   - Integrates external evidence from The Guardian and Wikipedia.
   - Serves verification, live news, summarization, and AI chat.

---

## Frontend Feature Breakdown
The Flutter frontend is organized into feature modules located in `apps/frontend/lib/features`.

### Core User Flows
- `home`: Main app shell with bottom navigation.
- `splash`: Startup and authentication gateway.
- `auth`: Login, registration, and authentication state management.
- `search`: Global topic search and user discovery.
- `profile`: User profile, editing, preferences, help, payment, subscription, device management, privacy, and language settings.

### News and Verification
- `news`: News feed, article listings, search results, and article retrieval.
- `article`: Article detail pages with comments, likes, and related content.
- `bookmarks`: Save articles for later reading and manage saved content.
- `digest`: Daily or live verified digest view built from live Guardian news and backend digest data.
- `ai_assistant`: TruthBot chat interface for news questions and verification requests.

### Social and Community
- `social`: Follow/unfollow workflows, follower and following lists, public profiles.
- `chat`: One-to-one messaging, conversation lists, message sending, read receipts, and deletion.
- `chat` also contains support for incoming call interactions through `incoming_call_screen`.

### Games and Engagement
- `game`: Interactive content like news quiz, fact-fiction game, and chess gameplay screens.
- `chess`: Chess lobby, challenge flow, game state management, and move submission.

### Additional UX Features
- `profile` submodules include premium status, payment simulation, account privacy controls, user language preferences, reading history, and support/FAQ screens.
- The app uses polished glassmorphism styling, modern navigation transitions, and responsive layout components.

---

## Backend Details
The backend is a Laravel API gateway that supports app data, social features, and encrypted user sessions.

### Hosting and Deployment
- Render blueprint in `render.yaml` configures deployment for two services:
  - `truth-lens-backend` – Laravel API service.
  - `truth-lens-ml-service` – Python Flask microservice.
- Backend exposes `/api/health-check` for production health monitoring.
- The backend Dockerfile is configured to run Apache on port `10000`.

### Database
- Primary database engine: **MySQL**.
- The Render deployment is configured to connect through a TiDB Cloud gateway:
  - Host: `gateway01.ap-southeast-1.prod.aws.tidbcloud.com`
  - Port: `3306`
  - Database: configured via Render secrets (`DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`)
- Local development defaults to `sqlite` but supports MySQL, MariaDB, PostgreSQL, and SQL Server if configured.
- Database schema includes tables for:
  - users, password reset tokens
  - news articles, bookmarks
  - comments, comment likes
  - conversations, messages
  - calls, chess games
  - follows, user activities

### API and Endpoint Summary
`apps/backend/routes/api.php` documents public and protected routes.

Public endpoints:
- `POST /api/register` – register a new account.
- `POST /api/login` – authenticate and receive a JWT.
- `GET /api/news` – retrieve news feed.
- `GET /api/news/digest` – digest summaries.
- `GET /api/news/search` – search news content.
- `GET /api/news/{id}` – read a single article.
- `GET /api/users/search` – find users.
- `GET /api/users/{userId}/profile` – public profile data.
- `GET /api/follow/status/{userId}` – follow status lookup.

Protected endpoints (require `Authorization: Bearer <token>`):
- `POST /api/logout`
- `POST /api/refresh`
- `GET /api/me`
- `POST /api/profile`
- `POST /api/upgrade-premium`
- `POST /api/cancel-premium`
- Social: follow/unfollow, followers, following.
- Chat: user list, conversations, messages, mark read, delete message.
- Calls: initiate call, active calls, update call status.
- Chess: challenge, list games, accept/decline, move, resign, finish.
- News logging: `POST /api/news/{id}/log-read`.
- Bookmarks: list, create, delete.
- Comments: list, add, delete, like.

### Authentication
- Uses JWT for stateless authentication.
- `tymon/jwt-auth` package is configured through Laravel.
- `AuthController` handles login, registration, profile updates, refresh, logout, and premium actions.

### Local Startup and Environment
- Local backend startup is supported via `start_backend.sh`.
- The script auto-detects the local machine IP and rewrites `api_constants.dart` to point the Flutter app to local API servers.
- Local URLs are maintained in `apps/frontend/lib/core/services/api_constants.dart`:
  - Local backend: `http://10.0.2.2:8000/api`
  - Local ML service: `http://10.0.2.2:10000`
- Production URLs are also configured in the same file:
  - Backend: `https://truth-lens-backend-aa7e.onrender.com/api`
  - ML service: `https://truth-lens-ml-service.onrender.com`

---

## ML Service & Verification Methodology
The ML service is the intelligence layer that powers claim verification and AI responses.

### Service Functionality
Located in `apps/ml_service/app.py`, it exposes:
- `GET /` and `GET /api/` – service status.
- `GET /health` and `GET /api/health` – health and RAM usage.
- `POST /api/predict` – verify a claim and return:
  - `label`: REAL / FAKE / UNCERTAIN
  - `confidence`
  - `reason`
  - `sources`
- `GET /api/news/live` – fetch live headlines from The Guardian.
- `POST /api/summarize` – summarize long article text into concise points.
- `POST /api/bot/ask` – chat with TruthBot using a strict news-only instruction set.

### Verification Pipeline
The verification process follows a clear multi-stage pipeline:
1. Claim ingestion from the frontend.
2. Entity and keyword extraction using Gemini.
3. Evidence gathering from Wikipedia and The Guardian APIs.
4. Grounded reasoning by Gemini using the assembled evidence.
5. Output of a verdict with label, confidence, reason, and source citations.

### Evidence and Grounding
The ML service applies a multi-step verification methodology:
1. Extracts relevant search entities from the input claim using Gemini.
2. Searches Wikipedia for supporting context.
3. Queries The Guardian API for topical news evidence.
4. Constructs a grounded prompt for Gemini to label the claim.
5. Returns transparent reasoning, confidence, and source citations.

### Evaluation and Performance Metrics
Truth Lens is designed to monitor and improve quality through metrics such as:
- Accuracy: correctness of REAL/FAKE/UNCERTAIN labels.
- Precision: reliability of positive verification decisions.
- Recall: coverage of true claims and false claims found.
- Latency: speed of end-to-end verification from request to response.

A new evaluation helper is available at `apps/ml_service/evaluate_accuracy.py`. It can run against the local ML service and a labeled dataset file in JSON, JSONL, or CSV format.

### Evaluating Accuracy Locally
Run the local ML service first:
```bash
cd apps/ml_service
python app.py
```
Then run the evaluation script:
```bash
cd apps/ml_service
python evaluate_accuracy.py --show-details
```
To evaluate against a labeled dataset file:
```bash
python evaluate_accuracy.py --dataset /path/to/claims.csv --show-details
```
The dataset must include `title`, `text`, and `expected_label` fields.

### Deployment
- The ML service is deployed via Docker using `apps/ml_service/Dockerfile`.
- Render health checks target `/health`.
- Environment variables needed:
  - `GEMINI_API_KEY`
  - `GUARDIAN_API_KEY`
  - `PORT`

---

## Running the Project Locally
### Backend
```bash
cd apps/backend
composer install
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
php artisan migrate
php artisan serve --host=0.0.0.0 --port=8000
```

### ML Service
```bash
cd apps/ml_service
pip install -r requirements.txt
export GEMINI_API_KEY="your_gemini_key"
export GUARDIAN_API_KEY="your_guardian_key"
python app.py
```

### Frontend
```bash
cd apps/frontend
flutter pub get
flutter run
```

### Local Startup Script
Run `./start_backend.sh` from the repository root to launch the backend and ML service together and auto-configure the Flutter API constants.

---

## Technology Stack
- Flutter & Dart: frontend UI and native app architecture.
- Riverpod: state management.
- Laravel 12 / PHP 8.2+: backend API, authentication, social graph, and persistence.
- MySQL / TiDB-compatible gateway: primary datastore.
- Flask / Python 3.10: AI microservice.
- Google Gemini (Gemma-3-27b-it): claim verification and chat.
- The Guardian API + Wikipedia: external evidence and live news grounding.
- Docker: containerized deployment for backend and ML service.
- Render: cloud hosting blueprint for production services.

---

## Project Methodology
Truth Lens was built using a modular, evidence-driven development approach:
- **Research:** Identify misinformation workflows and the need for real-time verification.
- **Design:** Separate the product into frontend, backend, and intelligence services.
- **Implementation:** Build secure authentication, news retrieval, AI verification, social interaction, and engagement features.
- **Validation:** Use live API sources and AI grounding to reduce hallucination and improve trust.
- **Deployment:** Use Docker and Render for scalable hosted services.

This modular strategy allows each service to evolve independently while preserving a unified user experience.

---

## Notes
- The backend is production-ready with Docker and Render configuration.
- Local configuration supports both SQLite and MySQL.
- The ML service uses a fallback news dataset when live APIs fail.
- The frontend supports a polished multi-tab experience with story-driven verification and reporting.

For additional details, inspect the feature modules in `apps/frontend/lib/features`, the Laravel routes in `apps/backend/routes/api.php`, and the ML logic in `apps/ml_service/app.py`.
