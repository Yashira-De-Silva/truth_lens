# Truth Lens: AI-Powered News Verification System

## Abstract: Truth Lens

Misinformation in contemporary digital media is one of the most significant challenges to social cohesion and public trust, driven primarily by the rapid, viral spread of unverified claims and a lack of proactive, real-time authentication tools in traditional news consumption. Current verification processes often rely on manual reporting or static databases, which creates bottlenecks in addressing fast-moving news cycles. The aim of this project is to develop Truth Lens, an innovative AI-driven news verification system that utilizes Large Language Models (LLMs) and real-time external data retrieval to provide rapid, evidence-based classification of digital claims rather than static analysis alone.

The methodology involved an iterative development process to refine the interplay between the mobile interface, backend logic, and the machine learning engine. The system is built on a modular microservices architecture, featuring a responsive Flutter frontend that allows users to seamlessly consume live news, verify custom claims, and interact with an intelligent news assistant. The backend is powered by a Laravel 11 API gateway with JWT-based authentication to ensure secure data handling and user session persistence. To address the complexity of fact-checking, a dedicated Python Flask microservice was implemented for asynchronous AI inference, integrating the Google Gemini (Gemma-3-27b) model. This service performs automated entity extraction and cross-references user-submitted text against live data retrieved from the Wikipedia and The Guardian News APIs.

Results from the implementation phase indicate that Truth Lens successfully meets its primary objectives, delivering REAL/FAKE/UNCERTAIN labels with high-transparency confidence scores and source citations in seconds. The integrated architecture significantly reduces the time gap between encountering a suspicious claim and clinical fact-based verification. Furthermore, the implementation of "TruthBot" provides a strictly news-oriented conversational interface, ensuring users stay informed without the risk of AI-generated misinformation on non-relevant topics. These findings suggest that Truth Lens offers a portable, scalable, and cost-effective solution for digital fact-checking, potentially improving global media literacy and fostering a more trustworthy information ecosystem by facilitating timely information validation.

---

## Technical Architecture & Ecosystem

Truth Lens is engineered as a robust, tripartite monorepo, orchestrating independent services to achieve high scalability and performance.

### 📱 Frontend Application (`apps/frontend`)
The user-facing portal designed for high-engagement news consumption and verification.
- **Framework:** Flutter (Cross-platform iOS/Android)
- **State Management:** Riverpod (Reactive and predictable state)
- **Key Features:**
  - Real-time News Feed with categorized sections.
  - Interactive Fact-Checking Dashboard for custom text/news verification.
  - **TruthBot Interface:** A custom-styled chat interface for AI-driven news inquiries.
  - Secure Authentication flow with JWT integration.
  - Integrated Local & AI Chess gameplay for user engagement.

### ⚙️ Core Backend API (`apps/backend`)
The orchestrator and secure data layer of the Truth Lens ecosystem.
- **Framework:** Laravel 11 (PHP 8.2+)
- **Security:** Stateless JWT Authentication (`tymon/jwt-auth`)
- **Database:** MySQL
- **Key Features:**
  - Secure User Lifecycle Management (Registration, Login, Profile).
  - Centralized API Gateway for frontend-backend communication.
  - Robust Error Handling and validation for all consumer endpoints.

### 🤖 Machine Learning Microservice (`apps/ml_service`)
The computational core that powers the intelligence of the system.
- **Framework:** Python 3 / Flask
- **AI Engine:** Google Gemini (Gemma-3-27b-it)
- **Data Integrations:** Wikipedia API & The Guardian API
- **Key Capabilities:**
  - **Live Verification (`/api/predict`):** Dynamically extracts searchable entities from claims and cross-references them with live web evidence.
  - **Intelligent Summarization:** Condenses complex articles into concise, verifiable bullet points.
  - **TruthBot Brain:** Powers the conversational news assistant with strict domain-specific instructions.
  - **Live Data Streaming:** Bridges the frontend with real-world news events.

---

## Technology Stack Summary

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Mobile** | Flutter / Dart | UI & Cross-platform deployment |
| **API Backend** | Laravel 11 / PHP | Auth, Orchestration, & Main DB |
| **Intelligence** | Python / Flask | ML Inference & Web Integration |
| **LLM Model** | Gemini (Gemma-3) | Language understanding & Fact-checking |
| **External Data** | The Guardian / Wikipedia | Real-time source grounding |
| **Security** | JWT / BCrypt | Encryption & Access Control |

---

## Getting Started

To operate the full Truth Lens ecosystem, all three services must be initialized.

### Prerequisites
- Flutter SDK (>= 3.9)
- PHP >= 8.1 & Composer
- Python >= 3.9 & Pip
- MySQL Server
- Google Gemini API Key

### Installation Steps

1.  **Backend Setup:**
    ```bash
    cd apps/backend
    composer install
    cp .env.example .env # Configure DB_DATABASE, etc.
    php artisan key:generate && php artisan jwt:secret
    php artisan migrate
    php artisan serve
    ```

2.  **ML Service Setup:**
    ```bash
    cd apps/ml_service
    pip install -r requirements.txt
    # Export GEMINI_API_KEY environment variable
    python app.py
    ```

3.  **Frontend Setup:**
    ```bash
    cd apps/frontend
    flutter pub get
    flutter run
    ```


---

## Getting Started

To operate Truth Lens locally, each service must be initialized in parallel.

### Prerequisites
- **Frontend:** Flutter SDK (>= 3.9).
- **Backend:** PHP >= 8.0, Composer, MySQL server.
- **ML Service:** Python >= 3.9. Request corresponding API Keys (Gemini API, Guardian API).

### 1. Initialize the Laravel Backend
```bash
cd apps/backend
composer install
cp .env.example .env
# Update .env with MySQL credentials
php artisan key:generate
php artisan jwt:secret
php artisan migrate
php artisan serve
```

### 2. Initialize the ML Microservice
```bash
cd apps/ml_service
pip install -r requirements.txt
# Ensure GEMINI_API_KEY and GUARDIAN_API_KEY environment variables are specified
python app.py
```

### 3. Launch the Flutter App
```bash
cd apps/frontend
flutter pub get
flutter run
```

*For more detailed, service-specific instructions, please reference the `README.md` documents enclosed within their respective module directories.*
