# TruthLens – Interim Report

> **Student Name:** Yashira De Silva
> **Index Number:** 10953371
> **Module:** PUSL3190 Computing Project
> **Supervisor:** Mrs. Nimesha Hewawasam
> **Date:** March 2026

---

## Table of Contents

- [Chapter 01 – Introduction](#chapter-01--introduction)
  - [1.1 Introduction](#11-introduction)
  - [1.2 Problem Definition](#12-problem-definition)
  - [1.3 Project Objectives](#13-project-objectives)
- [Chapter 02 – System Analysis](#chapter-02--system-analysis)
  - [2.1 Facts Gathering Techniques](#21-facts-gathering-techniques)
  - [2.2 Existing System](#22-existing-system)
  - [2.3 Drawbacks of the Existing System](#23-drawbacks-of-the-existing-system)
- [Chapter 03 – Requirements Specification](#chapter-03--requirements-specification)
  - [3.1 Functional Requirements](#31-functional-requirements)
  - [3.2 Non-Functional Requirements](#32-non-functional-requirements)
  - [3.3 Hardware / Software Requirements](#33-hardware--software-requirements)
  - [3.4 Networking Requirements](#34-networking-requirements)
- [Chapter 04 – Feasibility Study](#chapter-04--feasibility-study)
  - [4.1 Operational Feasibility](#41-operational-feasibility)
  - [4.2 Economical Feasibility](#42-economical-feasibility)
  - [4.3 Technical Feasibility](#43-technical-feasibility)
- [Chapter 05 – System Design](#chapter-05--system-design)
  - [5.1 System Architecture](#51-system-architecture)
  - [5.2 Use Case Diagram](#52-use-case-diagram)
  - [5.3 Class Diagram](#53-class-diagram)
  - [5.4 ER Diagram](#54-er-diagram)
  - [5.5 Activity Diagram – Article Analysis](#55-activity-diagram--article-analysis)
  - [5.6 Sequence Diagram – User Login](#56-sequence-diagram--user-login)
- [Chapter 06 – Development Tools & Technologies](#chapter-06--development-tools--technologies)
  - [6.1 Frontend Technologies](#61-frontend-technologies)
  - [6.2 Backend Technologies](#62-backend-technologies)
  - [6.3 AI / ML Technologies](#63-ai--ml-technologies)
  - [6.4 Development Tools](#64-development-tools)
- [Chapter 07 – Implementation Progress](#chapter-07--implementation-progress)
  - [7.1 Progress Summary](#71-progress-summary)
  - [7.2 Backend Implementation](#72-backend-implementation)
  - [7.3 Frontend Implementation](#73-frontend-implementation)
  - [7.4 AI Integration](#74-ai-integration)
  - [7.5 Project Timeline](#75-project-timeline)
- [Chapter 08 – Conclusion](#chapter-08--conclusion)
  - [8.1 Summary of Work Done](#81-summary-of-work-done)
  - [8.2 Challenges Faced](#82-challenges-faced)
  - [8.3 Future Work](#83-future-work)

---

## Chapter 01 – Introduction

### 1.1 Introduction

The exponential growth of social media and digital news platforms has made information more accessible than ever before. However, this accessibility comes at a significant cost — the rapid, unchecked spread of misinformation, disinformation, and fabricated news poses severe threats to public trust, democratic processes, personal health decisions, and individual decision-making capacity.

**TruthLens** is a cross-platform mobile application designed to combat this critical problem by leveraging Artificial Intelligence (AI), Natural Language Processing (NLP), and interactive gamification to help users identify, evaluate, and understand the credibility of news articles and online content in real time.

The application provides users with AI-powered analysis tools, credibility scores, fact-checking chat features, a personalised news digest, and media literacy educational resources — all within an intuitive, accessible interface designed for everyday use.

The system is built using a robust multi-tier architecture:

- **Flutter (Dart)** — Cross-platform mobile frontend targeting Android and iOS
- **Laravel 12 (PHP 8.2+)** — RESTful backend API with JWT-based secure authentication
- **FastAPI (Python)** — Dedicated microservice for AI/NLP model inference
- **Firebase** — Real-time database and push notification services

Together, these technologies deliver a scalable, secure, and performant platform capable of real-time content analysis and interactive user engagement.

---

### 1.2 Problem Definition

The modern information landscape presents the following core challenges:

1. **Volume and Speed:** Millions of news articles and social media posts are published daily, making manual fact-checking impossible at scale. Misinformation can go viral within hours.
2. **Credibility Ambiguity:** Average users lack reliable, fast, and accessible tools to assess the trustworthiness of a news source or article without conducting extensive independent research.
3. **Misinformation Spread:** False or misleading content tends to spread significantly faster than corrections, creating lasting public confusion on critical topics such as health policy, political discourse, and climate change.
4. **Lack of Media Literacy:** Many users are not equipped with the skills or resources to critically evaluate the news they consume, making them vulnerable to manipulation and confirmation bias.
5. **Fragmented Tooling:** Existing fact-checking resources are predominantly website-based, require significant manual effort, and are poorly integrated into users' everyday mobile news consumption habits.

The core problem is therefore: **there is no widely accessible, AI-powered, mobile-first platform that provides real-time credibility analysis of news content alongside interactive educational tools — all in a single, unified application.**

---

### 1.3 Project Objectives

The primary objectives of the TruthLens project are:

1. **Develop a cross-platform mobile application** (iOS and Android) using Flutter that delivers a seamless, responsive, and engaging user experience.
2. **Implement AI-powered content analysis** using NLP (BERT-based models via FastAPI) to assess the credibility and potential bias of news articles provided by URL or text input.
3. **Provide a real-time AI chat assistant** that allows users to ask fact-checking questions and receive evidence-based, sourced responses powered by a Large Language Model (LLM).
4. **Offer a personalised news digest** that aggregates news from multiple verified sources, filtered and ranked by credibility score.
5. **Enable article bookmarking and search** so users can save, revisit, and share credible content across sessions.
6. **Build a secure, scalable backend API** using Laravel 12 with JWT authentication to manage user accounts, preferences, analysis history, and data integrity.
7. **Incorporate educational gamification** (Fact vs Fiction quiz, media literacy challenges, badges, and a points-based reward system) to engage users and actively improve digital literacy.
8. **Support multilingual localisation** (English, Sinhala, and Tamil) using Flutter's internationalisation framework to make the platform accessible to a broader user base.
9. **Integrate real-time social features** including article discussion threads and user messaging to foster community-based fact verification.

---

## Chapter 02 – System Analysis

### 2.1 Facts Gathering Techniques

The following research techniques were employed to understand the problem domain, gather requirements, and inform the system design:

- **Literature Review** — Reviewed academic papers on fake news detection, NLP-based credibility scoring (BERT, RoBERTa), and media literacy frameworks from IEEE, ACM, and Google Scholar.
- **Existing System Analysis** — Evaluated existing tools including Snopes, FactCheck.org, NewsGuard, ClaimBuster, and Google Fact Check Tools to identify capability gaps and user pain points.
- **User Surveys** — Conducted informal surveys among university students and young professionals to understand mobile news consumption habits, fact-checking behaviours, and pain points.
- **Prototype Walkthroughs** — Created early wireframes and interactive mockups using Figma, gathering iterative usability feedback on navigation, feature layout, and visual design.
- **Technical Documentation Review** — Studied official documentation for Flutter, Laravel 12, FastAPI, Firebase SDK, BERT NLP models, and JWT authentication libraries to assess integration feasibility.
- **Industry Reports** — Referenced the Reuters Institute Digital News Report 2024, MIT Media Lab misinformation studies, and WHO reports on health misinformation for project contextualisation.
- **Supervisor Consultations** — Regular meetings with project supervisor Mrs. Nimesha Hewawasam to validate the project scope, technical direction, and interim deliverables.

---

### 2.2 Existing System

Several platforms currently address fake news and misinformation detection to varying degrees. A comparative analysis of key tools is provided below:

- **Snopes** — One of the oldest and most respected fact-checking websites, covering viral claims, urban legends, and news stories. Web-based and entirely manual; no mobile application.
- **FactCheck.org** — Nonpartisan fact-checking site focusing on political claims and statements by public figures in the USA. US-centric with no automated AI analysis.
- **NewsGuard** — Browser extension that rates news websites for credibility using human analyst teams. Requires a desktop browser; no NLP processing; subscription-based.
- **Google Fact Check Tools** — Aggregates structured fact checks from verified publishers and surfaces them in Google Search results. Passive tool with no interactive features; predominantly English-only.
- **PolitiFact** — Focuses on US political claims using a "Truth-O-Meter" scale rated by journalists. Limited in scope; no mobile app; US-only focus.
- **ClaimBuster** — AI-assisted tool for identifying check-worthy factual claims in text content. Narrow scope (detection only); no mobile access; no full credibility scoring pipeline.

---

### 2.3 Drawbacks of the Existing System

Despite the existence of the tools described above, several critical limitations prevent them from fully solving the misinformation challenge:

1. **Not Mobile-First** — Most tools are websites or browser extensions with no dedicated, optimised mobile application to support on-the-go use cases.
2. **Manual & Slow Verification** — The most authoritative fact-checking services (Snopes, FactCheck.org, PolitiFact) rely entirely on human journalists, meaning coverage is limited and verification can take hours or days.
3. **Narrow Feature Scope** — Existing AI tools (e.g., ClaimBuster) address only isolated tasks such as claim detection, without providing a full end-to-end pipeline including credibility scoring, source analysis, and personalised user guidance.
4. **No Personalisation** — None of the evaluated tools offer personalised news digests, reading history tracking, or adaptive recommendations tailored to individual users' preferences and literacy levels.
5. **No Interactive Learning** — All reviewed tools are passive information sources. There is no gamification, interactive quiz, or community feature to actively build media literacy skills.
6. **No Conversational Interface** — Users cannot engage in dialogue or ask follow-up questions about an article's credibility — they receive a static verdict with limited context or explanation.
7. **Language Limitations** — The majority of tools operate exclusively in English, severely restricting accessibility for non-English-speaking communities.
8. **No Unified Workflow** — Users must switch between multiple tools (browser, search engine, fact-checking site) to research a single article — there is no integrated, mobile-first workflow.

---

## Chapter 03 – Requirements Specification

### 3.1 Functional Requirements

The following functional requirements define what the TruthLens system must be capable of delivering:

#### 3.1.1 Authentication & User Management

- **FR-01** — Users must be able to register a new account using an email address and secure password.
- **FR-02** — Users must be able to log in and receive a secure JWT access token for API authentication.
- **FR-03** — Users must be able to log in using Google OAuth via Google Sign-In (via Laravel Socialite).
- **FR-04** — Users must be able to view and update their profile information including display name and avatar.
- **FR-05** — Users must be able to securely log out, invalidating all active authentication tokens.

#### 3.1.2 News & Article Analysis

- **FR-06** — Users must be able to submit a news article URL or raw text for AI-powered credibility analysis.
- **FR-07** — The system must return a credibility score (0–100) and a natural-language summary of analysis findings.
- **FR-08** — Users must be able to browse a curated, credibility-ranked news digest aggregated from multiple verified sources.
- **FR-09** — Users must be able to search for news articles and fact-checks by keyword, topic, or source.

#### 3.1.3 AI Chat Assistant

- **FR-10** — Users must be able to engage in real-time conversational AI chat to submit fact-checking queries.
- **FR-11** — The AI assistant must provide sourced, evidence-based responses referencing credible publications.

#### 3.1.4 Bookmarks

- **FR-12** — Users must be able to bookmark articles and analysis results for later reference.
- **FR-13** — Users must be able to view, organise, and delete their list of bookmarked articles.

#### 3.1.5 Gamification & Media Literacy

- **FR-14** — The application must include a Fact vs Fiction quiz game to educate users on identifying misinformation.
- **FR-15** — The system must award points and badges (e.g., "Fact Checker", "Truth Seeker") for quiz completions and app engagement.
- **FR-16** — A leaderboard must display top-scoring users to encourage competitive engagement.

#### 3.1.6 Social Features

- **FR-17** — Users must be able to view other users' public profiles and activity summaries.
- **FR-18** — Users must be able to participate in discussion threads attached to specific articles.

#### 3.1.7 Localisation

- **FR-19** — The application must support English, Sinhala, and Tamil languages via Flutter's localisation framework.
- **FR-20** — Users must be able to switch the application language from within the profile/settings screen.

---

### 3.2 Non-Functional Requirements

- **NFR-01 – Performance** — API responses must be returned within 2 seconds under normal network conditions for all standard endpoints.
- **NFR-02 – Scalability** — The backend must support horizontal scaling to accommodate growing user demand without degradation of performance.
- **NFR-03 – Security** — All protected API endpoints must require JWT authentication. Passwords must be hashed using bcrypt with a minimum cost factor of 10.
- **NFR-04 – Usability** — The mobile UI must follow Material Design 3 guidelines and be accessible to users with no technical background.
- **NFR-05 – Availability** — The backend API must target 99.5% uptime in the production environment.
- **NFR-06 – Maintainability** — Code must follow PSR-12 (PHP), Dart/Flutter style guidelines, and PEP 8 (Python); all components must be modular and documented.
- **NFR-07 – Portability** — The Flutter frontend must run natively on Android (API Level 21+) and iOS (12.0+) without platform-specific degradation.
- **NFR-08 – Privacy** — User personally identifiable information (PII) must not be logged, cached, or exposed in API responses beyond what is necessary.
- **NFR-09 – Reliability** — The AI analysis service must implement graceful degradation — if the FastAPI service is unavailable, the system must return a meaningful error and not crash the mobile application.

---

### 3.3 Hardware / Software Requirements

#### Development Environment

- **Operating System** — macOS 12+ / Windows 10+ / Ubuntu 20.04+
- **RAM** — Minimum 8 GB (16 GB recommended for running emulator and server simultaneously)
- **Storage** — Minimum 20 GB free disk space
- **CPU** — Intel Core i5 / Apple M1 or equivalent

#### Software Requirements

- **Mobile Frontend** — Flutter SDK 3.x (Dart 3.x)
- **Backend Framework** — Laravel 12 (PHP ≥ 8.2)
- **AI Microservice** — FastAPI (Python 3.11+)
- **Real-time Database** — Firebase Firestore (Flutter SDK)
- **Relational Database** — MySQL 8.0+
- **Authentication** — tymon/jwt-auth 2.x (Laravel)
- **Social Auth** — Laravel Socialite 5.x / Google Sign-In Flutter
- **State Management** — Flutter Riverpod 2.x
- **NLP Model** — BERT (via HuggingFace Transformers)
- **HTTP Client** — Dart `http` / `dio` package
- **Version Control** — Git / GitHub
- **Package Manager (PHP)** — Composer 2.x
- **Package Manager (Dart)** — pub (Flutter)
- **IDE** — VS Code / Android Studio / IntelliJ IDEA
- **API Testing** — Postman / Insomnia
- **Android Emulator** — Android Studio AVD (API 21+)
- **iOS Simulator** — Xcode 14+ (macOS only)

#### Runtime / Deployment Requirements

- **Web Server** — Apache / Nginx with PHP-FPM
- **PHP** — Version 8.2 or higher
- **MySQL** — Version 8.0 or higher
- **Python Runtime** — Version 3.11+ (for FastAPI service)
- **SSL Certificate** — Required for production HTTPS (Let's Encrypt — free)
- **Mobile Device** — Android 5.0+ (API 21+) or iOS 12.0+
- **Firebase Project** — Active Firebase project with Firestore and Cloud Messaging enabled

---

### 3.4 Networking Requirements

- **API Protocol** — RESTful HTTP/HTTPS API with JSON payloads
- **Data Format** — JSON (`application/json`)
- **Authentication Header** — `Authorization: Bearer <JWT>` required on all protected endpoints
- **Internet Connectivity** — Active internet connection required for article analysis, AI chat, and news digest features
- **API Base URL** — Configurable via environment variable (`API_BASE_URL`) for environment switching
- **CORS Policy** — Backend must enforce strict CORS rules, permitting only authorised mobile and web client origins
- **Rate Limiting** — API endpoints must implement rate limiting (60 requests/minute per authenticated user)
- **Ports** — Backend: 8000 (development), 443 (production HTTPS); FastAPI: 8001 (internal)
- **Firebase Connection** — Persistent WebSocket connection via Firebase SDK for real-time data synchronisation

---

## Chapter 04 – Feasibility Study

### 4.1 Operational Feasibility

TruthLens is operationally feasible for the following reasons:

- **Demonstrated User Demand** — There is significant and growing public need for accessible misinformation detection tools, particularly on mobile platforms. Global media literacy initiatives (UNESCO, WHO) and academic research consistently demonstrate this demand.
- **Ease of Use** — The Flutter-based interface is designed to be intuitive for non-technical users using familiar Material Design 3 patterns. Onboarding flows and guided navigation minimise the learning curve.
- **Automated Operations** — Core functionality — article analysis, credibility scoring, and AI chat — is fully automated via AI/ML microservices, reducing reliance on human effort and enabling 24/7 operation.
- **Engagement Through Gamification** — The integration of the Fact vs Fiction quiz, badge systems, and a points leaderboard encourages habitual engagement and long-term user retention.
- **Maintainability** — The modular architecture (Laravel MVC backend, feature-based Flutter folder structure, separate FastAPI service) supports straightforward maintenance and iterative development.

> **Conclusion:** The system is operationally feasible. It addresses a well-defined, real-world problem; requires no specialist hardware from end users; and can operate with minimal ongoing human oversight beyond routine maintenance.

---

### 4.2 Economical Feasibility

Estimated costs for the project are as follows:

- **Development Labour** — £0 (academic project, developed by student contributor)
- **Backend Hosting** — £5–£20/month (VPS such as DigitalOcean, Railway, or Fly.io)
- **Database (MySQL)** — £0–£10/month (typically included with most hosting plans)
- **FastAPI Hosting** — £0–£10/month (lightweight Python server instance)
- **Firebase** — £0–£25/month (generous free tier; pay-as-you-go for scale)
- **AI / NLP API** — £0–£50/month (free tiers available via OpenAI and Google Gemini)
- **Domain Name** — ~£10/year (one-time or annual recurring cost)
- **SSL Certificate** — £0 (Let's Encrypt, free)
- **App Store Distribution** — £25 (Google Play, one-time) / £99/year (Apple Developer Program)
- **Total Estimated (MVP)** — ~£40–£215/month, highly scalable based on user volume

**Projected Benefits:**

- Potential path to monetisation through a freemium model (premium AI analysis credits, ad-free experience, advanced analytics).
- Significant social value through improved digital literacy, public trust, and reduced misinformation impact.
- Low barrier to entry makes the project viable within both academic and early-stage startup budgets.

> **Conclusion:** The project is economically feasible at both development and operational stages. Open-source frameworks (Laravel, Flutter, FastAPI) eliminate all licensing costs, and cloud hosting keeps operational costs well within a student or startup budget.

---

### 4.3 Technical Feasibility

- **Technology Maturity** — All core technologies (Flutter 3.x, Laravel 12, FastAPI, MySQL 8, Firebase) are production-grade, well-documented, and widely adopted across the industry.
- **AI Integration** — BERT-based NLP models via HuggingFace Transformers and LLM APIs (OpenAI GPT-4, Google Gemini) provide reliable, well-documented interfaces for content analysis and conversational AI.
- **Cross-Platform Capability** — Flutter's single codebase compiles natively to Android, iOS, web, and desktop — maximising reach with minimal additional development overhead.
- **Security** — JWT authentication, bcrypt password hashing, HTTPS enforcement, Firebase security rules, and CORS policies provide a solid, industry-standard security baseline.
- **Scalability** — Laravel's queue system, caching (Redis), and support for containerised deployment (Docker, AWS, GCP) enable horizontal scaling. FastAPI's async nature handles concurrent inference efficiently.
- **Developer Competence** — The developer has demonstrated competency in Flutter, Laravel, and Python development, with existing backend API endpoints and Flutter screens already implemented.
- **Third-Party Risk** — External AI API availability and rate limits represent the primary technical risk; mitigated by designing the system with abstraction layers to support multiple AI providers as fallbacks.

> **Conclusion:** The project is technically feasible. The selected technology stack is proven, the developer has the requisite skills, and the architecture is designed to scale. The primary risk — AI API reliability — is manageable through appropriate service abstraction and fallback strategies.

---

## Chapter 05 – System Design

### 5.1 System Architecture

TruthLens follows a **multi-tier, microservices-influenced architecture** to ensure separation of concerns, scalability, and maintainability.

```
┌────────────────────────────┐
│      Flutter Mobile App    │  ← Android / iOS (Dart + Riverpod)
│  (Frontend Client Layer)   │
└─────────────┬──────────────┘
              │ HTTPS / REST API (JSON)
              │ Firebase SDK (WebSocket)
              ▼
┌────────────────────────────┐     ┌──────────────────────────┐
│     Laravel 12 Backend     │────▶│    FastAPI AI Service     │
│  (RESTful API + JWT Auth)  │     │  (NLP Inference – BERT)  │
│       PHP 8.2+ / MySQL     │     │       Python 3.11+        │
└─────────────┬──────────────┘     └──────────────────────────┘
              │
              ▼
┌────────────────────────────┐     ┌──────────────────────────┐
│       MySQL Database       │     │   Firebase Firestore      │
│  (Users, Articles, Auth)   │     │  (Real-time / Messaging)  │
└────────────────────────────┘     └──────────────────────────┘
```

**Key Architecture Decisions:**

- **Flutter Frontend** — Single codebase for Android and iOS reduces development time and maintenance overhead.
- **Laravel REST API** — Mature PHP framework with built-in ORM (Eloquent), queue management, and JWT integration.
- **FastAPI AI Microservice** — Python's ML ecosystem (PyTorch, HuggingFace) far exceeds PHP for AI tasks; isolating AI in a dedicated service prevents blocking the main API.
- **Firebase Firestore** — Native real-time synchronisation required for messaging and live notifications at low cost.
- **JWT Authentication** — Stateless, scalable token-based auth suited for mobile applications with no session affinity requirements.

---

### 5.2 Use Case Diagram

> See [DIAGRAMS_README.md](./DIAGRAMS_README.md) for the full Mermaid source to generate all diagrams.

**Actors:**

- **Guest User** — Can view limited public news feed
- **Registered User** — Full access to all features
- **System (AI Service)** — Performs automated credibility analysis

**Key Use Cases:**

- Register / Login / Social Login (Google OAuth)
- Submit Article for Credibility Analysis
- Browse Personalised News Digest
- Use AI Fact-Checking Chat
- Bookmark Articles
- Play Fact vs Fiction Quiz
- View Badges & Leaderboard
- Switch Application Language

---

### 5.3 Class Diagram

**Core Domain Classes:**

- **`User`** — Attributes: id, name, email, password_hash, locale, points. Methods: register(), login(), logout(), updateProfile()
- **`Article`** — Attributes: id, url, title, content, credibility_score, source. Methods: analyse(), bookmark(), share()
- **`AnalysisResult`** — Attributes: id, article_id, user_id, score, summary, created_at. Methods: getScore(), getSummary()
- **`Bookmark`** — Attributes: id, user_id, article_id, created_at. Methods: save(), remove()
- **`ChatSession`** — Attributes: id, user_id, messages[], created_at. Methods: sendMessage(), getHistory()
- **`QuizGame`** — Attributes: id, user_id, score, questions[], completed_at. Methods: start(), submitAnswer(), getScore()
- **`Badge`** — Attributes: id, name, description, icon_url, criteria. Methods: award(), check()
- **`UserBadge`** — Attributes: user_id, badge_id, awarded_at

---

### 5.4 ER Diagram

**Core Database Entities and Relationships:**

```
users (id PK, name, email UNIQUE, password, google_id, locale, points, created_at)
  │
  ├──< bookmarks (id PK, user_id FK, article_id FK, created_at)
  │
  ├──< analysis_results (id PK, user_id FK, article_id FK, credibility_score, summary, created_at)
  │
  ├──< chat_sessions (id PK, user_id FK, created_at)
  │       └──< chat_messages (id PK, session_id FK, role, content, created_at)
  │
  ├──< quiz_attempts (id PK, user_id FK, score, total_questions, completed_at)
  │
  └──< user_badges (user_id FK, badge_id FK, awarded_at)
          └── badges (id PK, name, description, icon_url, criteria_json)

articles (id PK, url UNIQUE, title, body, source, published_at, cached_score)
  └──< bookmarks (referenced above)
  └──< analysis_results (referenced above)
```

---

### 5.5 Activity Diagram – Article Analysis

> See [DIAGRAMS_README.md](./DIAGRAMS_README.md) for Mermaid source.

**Flow:**

1. User submits article URL or text
2. Laravel API validates input and checks cache for existing result
3. If cached: return stored result
4. If new: forward to FastAPI AI service
5. FastAPI runs BERT-based NLP model on article content
6. Score and summary returned to Laravel API
7. Result stored in database and returned to Flutter app
8. Flutter UI displays credibility score, summary, and analysis detail

---

### 5.6 Sequence Diagram – User Login

> See [DIAGRAMS_README.md](./DIAGRAMS_README.md) for Mermaid source.

**Flow:**

1. User enters credentials in Flutter login screen
2. Flutter sends POST /api/auth/login to Laravel API
3. Laravel validates credentials against MySQL users table
4. On success: JWT token generated and returned
5. Flutter stores JWT in secure storage (flutter_secure_storage)
6. Subsequent API calls include `Authorization: Bearer <token>`

---

## Chapter 06 – Development Tools & Technologies

### 6.1 Frontend Technologies

- **Flutter** (SDK 3.x) — Cross-platform mobile framework targeting Android and iOS
- **Dart** (3.x) — Programming language used for all Flutter development
- **Riverpod** (2.x) — Reactive state management for Flutter
- **Go Router** (13.x) — Declarative routing and deep linking
- **Dio** (5.x) — HTTP client with interceptors for automatic JWT injection
- **flutter_secure_storage** (9.x) — Secure local storage for JWT tokens
- **google_sign_in** (6.x) — Google OAuth integration on Android and iOS
- **firebase_core / firebase_auth** (Latest) — Firebase SDK integration
- **intl** (Latest) — Internationalisation and localisation (EN / SI / TA)

### 6.2 Backend Technologies

- **Laravel** (12.x) — PHP RESTful API framework
- **PHP** (8.2+) — Backend programming language
- **MySQL** (8.0+) — Relational database for persistent storage
- **tymon/jwt-auth** (2.x) — JWT token generation and validation
- **Laravel Socialite** (5.x) — Google OAuth server-side flow
- **Eloquent ORM** — Database object-relational mapping (Laravel built-in)
- **Laravel Queue** — Async job processing for AI analysis tasks (Laravel built-in)
- **Redis** (7.x) — Caching layer for API responses and analysis results

### 6.3 AI / ML Technologies

- **FastAPI** (0.110+) — Python-based AI inference microservice
- **PyTorch** (2.x) — Deep learning framework for model inference
- **HuggingFace Transformers** (4.x) — Pre-trained BERT model for NLP tasks
- **scikit-learn** (1.x) — Supporting ML utilities
- **OpenAI API / Google Gemini** (Latest) — LLM for AI chat assistant responses
- **uvicorn** (0.29+) — ASGI server for running FastAPI

### 6.4 Development Tools

- **Git** (2.x) — Version control
- **GitHub** — Remote repository and team collaboration
- **Postman** — API endpoint testing and documentation
- **Android Studio** (Hedgehog+) — Flutter development IDE and Android AVD emulator
- **Xcode** (15+) — iOS simulator (macOS only)
- **VS Code** (Latest) — Backend and AI service development
- **Figma** — UI/UX wireframing and prototyping
- **Docker** (24+) — Containerisation for deployment

---

## Chapter 07 – Implementation Progress

### 7.1 Progress Summary

The following summarises the development progress as of the interim submission date:

**Completed ✅**

- Laravel project initialisation with Composer
- MySQL database schema — migrations for all core entities
- JWT authentication (login/register) — tested via Postman
- Google OAuth via Socialite — redirect and callback flows implemented
- User profile API — GET/PUT `/api/user` endpoints functional
- Article analysis API — URL and text submission endpoints complete
- FastAPI AI microservice — BERT model inference service running
- AI chat API proxy — Laravel proxies to OpenAI/Gemini API
- Bookmark API — CRUD endpoints functional
- Flutter project setup with feature-based folder structure
- Flutter auth screens — Login, Register, Google Sign-In
- Flutter news digest screen — displays news from backend
- Flutter article analysis screen — URL/text input + score display
- Flutter AI chat screen — conversational UI with message bubbles
- Flutter bookmark screen — saved articles list with removal
- Flutter profile screen — user details and settings view
- Dark mode support — theme toggle implemented via Riverpod

**In Progress 🔄**

- News digest API — news aggregation from external RSS/APIs
- Search API — full-text search implementation ongoing
- Flutter quiz/game screen — quiz logic 80% complete; scoring remaining
- Multilingual support — English complete; Sinhala/Tamil pending
- Firebase Firestore integration — collection structure designed; read/write in progress

---

### 7.2 Backend Implementation

The Laravel 12 backend provides a comprehensive RESTful API. The route structure is as follows:

```
/api/auth
  POST   /register           → Register new user
  POST   /login              → Login with JWT token response
  POST   /logout             → Invalidate JWT token
  GET    /auth/google        → Initiate Google OAuth flow
  GET    /auth/google/callback → Handle Google OAuth callback

/api/user
  GET    /user               → Get authenticated user profile
  PUT    /user               → Update user profile

/api/articles
  POST   /articles/analyse   → Submit URL or text for credibility analysis
  GET    /articles/digest    → Get personalised news digest
  GET    /articles/search    → Search articles by keyword

/api/chat
  POST   /chat/message       → Send message to AI fact-checking assistant

/api/bookmarks
  GET    /bookmarks          → List user's bookmarks
  POST   /bookmarks          → Add article to bookmarks
  DELETE /bookmarks/{id}     → Remove bookmark

/api/game
  GET    /game/quiz          → Get quiz questions
  POST   /game/quiz/submit   → Submit quiz answers and get score
  GET    /game/leaderboard   → Get top users leaderboard

/api/badges
  GET    /badges             → Get user's earned badges
```

---

### 7.3 Frontend Implementation

The Flutter application follows a **feature-first folder structure** for maintainability:

```
lib/
├── core/
│   ├── constants/           # App constants, API URLs, colours
│   ├── theme/               # Material 3 theme (light/dark)
│   ├── utils/               # Helper utilities
│   └── services/            # HTTP client, secure storage
├── features/
│   ├── auth/                # Login, Register, Google OAuth screens
│   ├── news/                # News digest feed and article cards
│   ├── article/             # Article submission and analysis result
│   ├── chat/                # AI chat interface
│   ├── bookmarks/           # Saved articles screen
│   ├── search/              # Search bar and results screen
│   ├── game/                # Fact vs Fiction quiz screen
│   ├── profile/             # User profile and settings
│   └── digest/              # Personalised news digest
└── main.dart                # Entry point with provider scope
```

---

### 7.4 AI Integration

The AI credibility analysis pipeline works as follows:

1. **Input** — User submits a news article URL or plain text via the Flutter app.
2. **Laravel API** receives the request, validates it, and checks the MySQL cache for an existing result.
3. **FastAPI Service** — If no cached result exists, Laravel forwards the content to the Python FastAPI microservice running on a dedicated port.
4. **NLP Processing** — FastAPI processes the text using a fine-tuned **BERT model** (from HuggingFace Transformers) trained on fake news detection datasets (e.g., LIAR dataset, FakeNewsNet).
5. **Scoring** — The model outputs a credibility score (0–100) and a classification label (Likely True / Uncertain / Likely False).
6. **Response** — The score and natural-language summary are returned to Laravel, stored in the database, and forwarded to the Flutter app.
7. **Display** — The Flutter UI renders the credibility score with a visual gauge, summary card, and detailed analysis breakdown.

---

### 7.5 Project Timeline

- **Phase 1 – Initiation** (Sep–Oct 2025) ✅ — Requirements gathering, PID submission, project planning
- **Phase 2 – Design** (Oct–Nov 2025) ✅ — System architecture, wireframes, database schema, UML diagrams
- **Phase 3 – Backend Development** (Nov–Dec 2025) ✅ — Laravel API, MySQL schema, JWT auth, Google OAuth
- **Phase 4 – AI Service** (Dec 2025) ✅ — FastAPI setup, BERT model integration, inference API
- **Phase 5 – Frontend Development** (Jan–Feb 2026) ✅ 85% — Flutter screens, state management, API integration
- **Phase 6 – Feature Completion** (Feb–Mar 2026) 🔄 — Search, multilingual, quiz, Firebase integration
- **Phase 7 – Testing** (Mar–Apr 2026) ⏳ — Unit testing, integration testing, user acceptance testing
- **Phase 8 – Final Submission** (Apr 2026) ⏳ — Report writing, presentation, deployment

---

## Chapter 08 – Conclusion

### 8.1 Summary of Work Done

Significant progress has been made on the TruthLens project since the project initiation phase. The following key deliverables have been completed at the interim stage:

- **Full Laravel 12 backend API** with JWT authentication, Google OAuth, user management, article analysis, AI chat proxy, and bookmark management endpoints — all tested and functional.
- **FastAPI AI microservice** with BERT-based NLP model integration providing credibility scoring and classification on submitted article content.
- **Flutter mobile frontend** with completed screens for authentication, news digest, article analysis, AI chat, bookmarks, profile management, and dark/light theme support.
- **Feature-based project architecture** established for both frontend and backend, enabling modular development and clean separation of concerns.
- **Database schema** fully migrated with all core entities (users, articles, analysis results, bookmarks, chat sessions, quiz attempts, badges) in place.

The project is on track according to the planned timeline, with approximately **85% of core features implemented** at the interim submission point.

---

### 8.2 Challenges Faced

- **AI Model Performance** — Initial BERT model inference was slow (>5s per request) on a standard VPS. Resolved by implementing async queued jobs in Laravel and switching to `DistilBERT` for faster inference.
- **Cross-Platform Auth** — Google Sign-In required different OAuth client IDs for Android and iOS. Resolved by configuring separate OAuth clients per platform in Firebase and Google Cloud Console.
- **Race Conditions in State** — Riverpod providers occasionally produced stale state in multi-screen navigation flows. Resolved by refactoring to the `AsyncNotifier` pattern with proper invalidation on navigation events.
- **Firebase + Laravel Dual Auth** — Managing authentication tokens for both Firebase SDK (real-time) and Laravel JWT simultaneously was complex. Resolved by introducing a token exchange endpoint where Laravel exchanges a Firebase token for a JWT.
- **CORS Configuration** — Early testing revealed CORS policy issues between Flutter web build and Laravel API. Resolved by configuring strict CORS middleware with a proper origin allowlist in Laravel.

---

### 8.3 Future Work

The following work remains to bring TruthLens to full project completion:

1. **Complete multilingual support** — Implement full Sinhala and Tamil translations using the `intl` package and ARB files.
2. **Finalise Firebase Firestore integration** — Complete real-time messaging and live notification features.
3. **Complete the Fact vs Fiction quiz game** — Finalise scoring logic, badge awarding, and the competitive leaderboard.
4. **Implement comprehensive search** — Build full-text search across the article dataset with filter and sort capabilities.
5. **Conduct user acceptance testing (UAT)** — Recruit target users (university students, young professionals) for structured testing sessions.
6. **Performance and security audit** — Conduct load testing (k6/Locust), penetration testing, and code security review before production deployment.
7. **Production deployment** — Containerise services with Docker and deploy to a cloud provider (DigitalOcean / Fly.io) with CI/CD pipelines.
8. **App Store submission** — Prepare store listings, screenshots, and compliance documentation for Google Play and Apple App Store.

---

## Project Structure Overview

```
truth_lens/
├── apps/
│   ├── backend/                    # Laravel 12 REST API
│   │   ├── app/
│   │   │   ├── Http/
│   │   │   │   ├── Controllers/    # API route controllers
│   │   │   │   └── Middleware/     # JWT & CORS middleware
│   │   │   ├── Models/             # Eloquent models (User, Article, etc.)
│   │   │   └── Providers/          # Service providers
│   │   ├── database/
│   │   │   ├── migrations/         # Database schema migrations
│   │   │   └── seeders/            # Development seed data
│   │   ├── routes/
│   │   │   └── api.php             # All API route definitions
│   │   └── .env.example            # Environment configuration template
│   │
│   ├── ai_service/                 # FastAPI Python AI Microservice
│   │   ├── main.py                 # FastAPI application entry point
│   │   ├── models/                 # BERT model loading and inference
│   │   └── requirements.txt        # Python dependencies
│   │
│   └── frontend/                   # Flutter cross-platform app
│       └── lib/
│           ├── core/               # Theme, constants, services
│           ├── features/
│           │   ├── auth/           # Login, register, Google OAuth
│           │   ├── news/           # News digest & article browsing
│           │   ├── article/        # Article credibility analysis
│           │   ├── chat/           # AI fact-checking chat
│           │   ├── bookmarks/      # Saved articles
│           │   ├── search/         # Content search
│           │   ├── game/           # Media literacy quiz/game
│           │   ├── profile/        # User profile & settings
│           │   └── digest/         # Personalised news digest
│           └── main.dart           # Application entry point
│
├── INTERIM_REPORT.md               # This document
└── DIAGRAMS_README.md              # Mermaid diagram source code
```

---

## Tech Stack Summary

- **Mobile Frontend** — Flutter (Dart) + Riverpod (SDK 3.x)
- **Backend API** — Laravel 12 (PHP 8.2+)
- **AI Microservice** — FastAPI + BERT via HuggingFace (Python 3.11+)
- **Authentication** — JWT (tymon/jwt-auth 2.x) + Google OAuth
- **Relational Database** — MySQL 8.0+
- **Real-time Database** — Firebase Firestore (Latest)
- **State Management** — Flutter Riverpod 2.x
- **Version Control** — Git / GitHub
- **Deployment Target** — DigitalOcean / Fly.io + Docker

---

_© 2026 – Student ID: 10953371 – Yashira De Silva – PUSL3190 Computing Project – All rights reserved._
