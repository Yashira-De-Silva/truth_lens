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
- **MySQL 8.0+** — Primary relational database for all persistent data storage

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
- **Technical Documentation Review** — Studied official documentation for Flutter, Laravel 12, FastAPI, MySQL 8, BERT NLP models, and JWT authentication libraries to assess integration feasibility.
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

- **Server:** Cloud-based VPS (e.g., DigitalOcean, Fly.io) for hosting the backend API and AI microservice.
- **Backend:** Laravel 12 (PHP 8.2+) for managing the primary REST API, with FastAPI (Python 3.11+) serving the AI model inference.
- **Frontend:** Flutter (Dart 3.x) for building a dynamic, cross-platform mobile application targeting Android and iOS.
- **Database:** MySQL 8.0+ for structured storage of user profiles, articles, analysis results, bookmarks, chat history, and badges, accessed via Laravel Eloquent ORM.
- **Authentication:** JWT-based token authentication (tymon/jwt-auth 2.x) with Google OAuth support via Laravel Socialite.
- **AI / NLP:** BERT model via HuggingFace Transformers running inside the FastAPI microservice for credibility inference.
- **State Management:** Flutter Riverpod 2.x for reactive state handling across the mobile application.
- **Version Control:** Git and GitHub for source control and collaboration.
- **Client:** Any Android 5.0+ (API 21+) or iOS 12.0+ mobile device capable of running the Flutter application.
- **Hardware (Development):** Minimum 8 GB RAM and an Intel Core i5 / Apple M1 processor (or equivalent) for running local emulators and development servers.

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

This will assess the cost effectiveness of the project, as well as the benefits of the project's implementation.

Open Source Cost Efficiency: The project has opted to use a cost-efficient set of technologies, such as Flutter, Laravel, FastAPI, and MySQL, which do not require the project to pay the high costs of purchasing proprietary software. All core frameworks are open-source and freely available.

Research & Data Sourcing: By using publicly available datasets and free-tier AI APIs (such as OpenAI and Google Gemini), the project has avoided the high costs of purchasing private data or commercial NLP solutions, keeping operational expenditure minimal.

Reduced Infrastructure Overhead: The project is developed by a single student contributor, eliminating development labour costs entirely. The backend is hosted on an affordable VPS, and the SSL certificate is provided free of charge via Let's Encrypt.

Scalable Infrastructure: The project's use of a modular microservices architecture (Laravel API + FastAPI AI service) allows the project to scale the resources used independently without incurring unnecessary cloud hosting costs as user demand grows.

> **Conclusion:** The project is economically feasible at both development and operational stages. Open-source frameworks (Laravel, Flutter, FastAPI) eliminate all licensing costs, and cloud hosting keeps operational costs well within a student or startup budget.

---

### 4.3 Technical Feasibility

- **Technology Maturity** — All core technologies (Flutter 3.x, Laravel 12, FastAPI, MySQL 8) are production-grade, well-documented, and widely adopted across the industry.
- **AI Integration** — BERT-based NLP models via HuggingFace Transformers and LLM APIs (OpenAI GPT-4, Google Gemini) provide reliable, well-documented interfaces for content analysis and conversational AI.
- **Cross-Platform Capability** — Flutter's single codebase compiles natively to Android, iOS, web, and desktop — maximising reach with minimal additional development overhead.
- **Security** — JWT authentication, bcrypt password hashing, HTTPS enforcement, MySQL access controls, and CORS policies provide a solid, industry-standard security baseline.
- **Scalability** — Laravel's queue system, caching (Redis), and support for containerised deployment (Docker, AWS, GCP) enable horizontal scaling. FastAPI's async nature handles concurrent inference efficiently.
- **Developer Competence** — The developer has demonstrated competency in Flutter, Laravel, and Python development, with existing backend API endpoints and Flutter screens already implemented.
- **Third-Party Risk** — External AI API availability and rate limits represent the primary technical risk; mitigated by designing the system with abstraction layers to support multiple AI providers as fallbacks.

> **Conclusion:** The project is technically feasible. The selected technology stack is proven, the developer has the requisite skills, and the architecture is designed to scale. The primary risk — AI API reliability — is manageable through appropriate service abstraction and fallback strategies.

---

## Chapter 05 – System Design

### 5.1 System Architecture

The diagram below illustrates the high-level multi-tier architecture of TruthLens, showing how the Flutter mobile app communicates with the Laravel backend API, the FastAPI AI microservice, and the MySQL database. The full Mermaid source is available in [DIAGRAMS_README.md](./DIAGRAMS_README.md).

```
┌────────────────────────────┐
│      Flutter Mobile App    │  ← Android / iOS (Dart + Riverpod)
│  (Frontend Client Layer)   │
└─────────────┬──────────────┘
              │ HTTPS / REST API (JSON)
              ▼
┌────────────────────────────┐     ┌──────────────────────────┐
│     Laravel 12 Backend     │────▶│    FastAPI AI Service     │
│  (RESTful API + JWT Auth)  │     │  (NLP Inference – BERT)  │
│       PHP 8.2+ / MySQL     │     │       Python 3.11+        │
└─────────────┬──────────────┘     └──────────────────────────┘
              │
              ▼
┌────────────────────────────┐
│       MySQL Database       │
│  (Users, Articles, Auth,   │
│   Bookmarks, Chat, Badges) │
└────────────────────────────┘
```

---

### 5.2 Use Case Diagram

The Use Case Diagram identifies the key actors in the system — Guest User, Registered User, and the AI System — and maps out all interactions available to each, including article submission, fact-checking chat, quiz participation, and profile management.

---

### 5.3 Class Diagram

The Class Diagram depicts the core domain classes of the TruthLens system, their attributes, methods, and the relationships between them, including User, Article, AnalysisResult, ChatSession, QuizAttempt, and Badge.

---

### 5.4 ER Diagram

The Entity-Relationship Diagram models the MySQL database schema, showing all tables, primary and foreign key relationships, and how entities such as users, articles, bookmarks, analysis results, and badges relate to one another.

---

### 5.5 Activity Diagram – Article Analysis

The Activity Diagram illustrates the step-by-step flow of an article credibility analysis request, from user submission through Laravel API validation, Redis cache lookup, FastAPI BERT inference, and the final result returned to the Flutter application.

---

### 5.6 Sequence Diagram – User Login

The Sequence Diagram shows the interaction between the Flutter app, the Laravel API, and the MySQL database during the user authentication flow, including JWT token generation and secure storage on the mobile device.

---

## Chapter 06 – Development Tools & Technologies

## Chapter 06 – Development Tools and Technologies

### 6.1 Development Methodology

The project is being executed following the Agile Methodology, adopting an iterative and incremental software development approach. Unlike the conventional "Waterfall" approach, Agile allows for refinement of individual components in parallel — for example, refining the AI inference service at the same time as developing new frontend screens — without blocking the overall development pipeline.

The importance of adopting this methodology for TruthLens lies in the nature of AI-powered systems, where the accuracy and confidence of the credibility analysis model must be evaluated and tuned iteratively based on real test inputs. By breaking development into short sprints, it is possible to bring core features — such as article analysis, user authentication, and the AI chat assistant — to a functional state early, and then refine them progressively until the final submission.

### 6.2 Programming Languages and Tools

The technology stack has been chosen to provide a clean separation between the mobile client, the business logic layer, and the AI engine.

Flutter (Frontend): Flutter has been chosen for building a dynamic, cross-platform mobile application targeting both Android and iOS from a single codebase. This allows for the development of a consistent, responsive user interface for features such as article credibility analysis, news digest, AI chat, and gamified quizzes, while minimising the overhead of maintaining separate native codebases.

Laravel 12 (Backend API): Laravel has been selected as the primary backend API framework. It handles all critical business logic including user authentication, article management, bookmark handling, and AI chat proxying. Laravel's built-in Eloquent ORM manages all interactions with the MySQL database, which stores user profiles, articles, analysis results, bookmarks, and badge data.

FastAPI (AI Microservice): FastAPI is a high-performance Python framework used to serve the AI inference pipeline. When a user submits an article for analysis, the Laravel API forwards the request to the FastAPI microservice, which runs the BERT-based NLP model and returns a credibility score and summary. FastAPI was chosen for its asynchronous request handling and seamless integration with the Python machine learning ecosystem.

MySQL 8.0+ (Database): MySQL serves as the single relational database for all persistent data across the system. All entities — users, articles, analysis results, chat sessions, bookmarks, quiz attempts, and badges — are stored and queried via Laravel's Eloquent ORM, keeping the data layer consistent and straightforward to maintain.

### 6.3 Third-Party Components and Libraries

To ensure that high-quality output is achieved, a number of well-established open-source libraries have been integrated into the project. On the frontend, Riverpod is used for reactive state management across the Flutter application, while Dio provides an HTTP client with automatic JWT injection for all authenticated API requests. The `flutter_secure_storage` package ensures that JWT tokens are stored securely on the device, and `google_sign_in` facilitates federated identity via Google OAuth on both Android and iOS.

On the backend, the `tymon/jwt-auth` library handles JWT token generation, validation, and refresh within Laravel. Laravel Socialite manages the Google OAuth server-side callback flow. Redis is used as a caching layer to store previously computed analysis results, reducing redundant AI inference calls and improving API response times.

For the AI microservice, HuggingFace Transformers provides access to pre-trained BERT and DistilBERT models for natural language processing, while PyTorch serves as the underlying deep learning runtime. The OpenAI API and Google Gemini API are used as the language model backends for the AI chat assistant feature.

### 6.4 Algorithms

The core algorithm used in TruthLens is a BERT-based (Bidirectional Encoder Representations from Transformers) natural language processing model for article credibility classification. BERT was selected over simpler approaches such as logistic regression or naive Bayes classifiers because of its ability to understand the contextual meaning of words within a sentence — both from left-to-right and right-to-left — making it significantly more effective at detecting subtle linguistic patterns associated with misinformation.

The reason BERT is used over a simpler model is its robustness when applied to diverse news content. As the model has been pre-trained on large corpora of text, it generalises well to new articles without requiring extensive domain-specific training data. For performance reasons, the lighter DistilBERT variant is used in production, which retains approximately 97% of BERT's accuracy at roughly half the inference time. The model outputs a credibility score between 0 and 100, which is then classified into three bands: Likely True (≥ 70), Uncertain (40–69), and Likely False (< 40).

---

## Chapter 07 – Implementation Progress

### 7.1 Development Environment Setup

In order to establish a solid and extensible software development process for the TruthLens project, a modern full-stack mobile development environment has been configured. It emphasises type safety, modular architecture, and database management efficiency.

- Prerequisites & Runtimes
  The project requires Flutter SDK 3.x and Dart 3.x for mobile development, PHP 8.2+ with Composer for the Laravel backend, and Python 3.11+ for the FastAPI AI microservice. A MySQL 8.0+ server is required locally to manage the structured relational storage of user data, articles, and analysis results.

- Project Structure & Configuration
  The project follows a feature-first folder structure on the Flutter frontend, separating concerns by feature module (auth, news, chat, bookmarks, game, profile). The Laravel backend is organised using the standard MVC pattern with dedicated Controllers, Models, and Migrations directories.

- Database ORM & Migration
  Laravel's built-in Eloquent ORM is used for all database interactions. Automated migration scripts define and version the database schema, ensuring consistency across development environments. All core entities — users, articles, analysis results, bookmarks, chat sessions, quiz attempts, and badges — have dedicated migration files.

- Environment Variables
  The project's security posture is maintained by separating sensitive credentials — database passwords, JWT secrets, API keys (OpenAI, Gemini) — into `.env` files, which are excluded from version control via `.gitignore`.

---

### 7.2 Implemented Features

Implementation has been carried out according to the Agile methodology. The basic infrastructure and necessary user workflows are now fully functional.

#### 7.2.1 Authentication & Security

- Secure Authentication
  The application has a secure authentication process through the use of JWT-based tokens generated by the `tymon/jwt-auth` library, combined with bcrypt password hashing for all stored credentials. Registration and login endpoints have been fully tested via Postman.

- Google OAuth (Social Login)
  The application supports federated identity via Google Sign-In on both Android and iOS. The Laravel Socialite library manages the OAuth callback flow server-side, and the `google_sign_in` Flutter package handles the mobile-side token acquisition. Separate OAuth client IDs are configured for Android and iOS platforms.

- Profile Management
  Users have the functional capability to manage their profiles, including viewing and editing display names and application preferences. The GET and PUT `/api/user` endpoints are implemented and functional, with corresponding Flutter profile screen built and integrated.

#### 7.2.2 Backend API & Database

- RESTful API Implementation
  The Laravel 12 backend exposes a comprehensive set of REST API endpoints covering authentication, user management, article analysis, AI chat, bookmarks, quiz, leaderboard, and badge retrieval. All endpoints are protected by JWT middleware and have been verified via Postman.

- MySQL Database Schema
  All core database entities are in place via Laravel migration files. The schema covers: users, articles, analysis_results, bookmarks, chat_sessions, chat_messages, quiz_attempts, badges, and user_badges tables with all necessary foreign key constraints.

- AI Chat Proxy API
  The Laravel backend successfully proxies user messages to the OpenAI GPT-4 or Google Gemini API, stores the conversation history (session + messages) in MySQL, and returns AI-generated responses to the Flutter client.

#### 7.2.3 Content & Analysis Features

- Article Credibility Analysis
  The application has successfully implemented the core feature of submitting a news article URL or plain text for AI-powered credibility analysis. The Flutter frontend sends the content to the Laravel API, which forwards it to the FastAPI BERT microservice, returning a credibility score (0–100), a classification label, and a natural-language summary.

- FastAPI AI Microservice
  The FastAPI Python microservice is running and serving BERT/DistilBERT model inference requests. It receives article content from the Laravel API, tokenises it, runs NLP inference, and returns a structured JSON result including the credibility score and summary.

- Personalised News Digest
  The application provides users with a news feed aggregated from external RSS sources. Articles are retrieved and displayed with their source, headline, and a cached credibility score where available.

- Article Bookmarking
  Users have the functional capability to bookmark any article for later reference. The bookmark CRUD API is complete, and the Flutter bookmark screen displays saved articles with the option to remove them individually.

#### 7.2.4 Mobile Frontend & UX

- Flutter Screens Implemented
  The following Flutter screens are fully built and integrated with the backend API: Login, Register, Google Sign-In, News Digest, Article Analysis (URL/text input + score display), AI Chat (conversational message bubbles), Bookmarks (saved articles list), and Profile (user details and settings).

- Dark Mode & Theming
  The application implements both light and dark themes using Material 3, with a toggle managed via Riverpod state. The theme preference persists locally across sessions.

#### 7.2.5 Gamification (Fully Implemented)

- Chess Game
  The application has successfully implemented a fully functional Chess game. Users choose to play as White or Black, with the AI opponent making random valid moves. The game features a live 8×8 chess board with piece highlighting, real-time check detection (highlighted in red on the king's square), a scrollable move history panel, and three outcome dialogs — Victory, Defeat, and Draw — triggered on checkmate, stalemate, or insufficient material. Users can reset and start a new game at any time.

- Fact vs Fiction Game
  The application has implemented a timed headline classification game. Users are presented with shuffled news headlines and must classify each as "FACT" or "FICTION" within a 15-second countdown. The scoring system awards points based on correctness plus a streak multiplier and time-remaining bonus. The game tracks a persistent local high score using `SharedPreferences`, displays real-time score, streak, and timer statistics, and shows an explanatory feedback card after each answer. A game-over dialog displays the final score and accuracy rate.

- News Quiz Challenge
  The application has implemented a multiple-choice media literacy quiz covering 8 questions on topics such as misinformation, deepfakes, confirmation bias, fact-checking, and clickbait. Each question presents four options (A–D) with colour-coded answer highlighting and a "Did you know?" explanation panel revealed after answering. A results screen displays the total score out of 80, percentage accuracy, and a contextual performance message, with options to replay or exit.

---

### 7.3 Screenshots / Code Snippets

The following table describes each screenshot to be captured for the final report, based on the implemented screens in the Flutter frontend codebase.

---

**Screenshot 1 — Login Screen**
Capture the Login screen showing the TruthLens logo ("TL" in white on a dark blue rounded square) and tagline "See the Truth Behind the News" at the top, followed by the glassmorphism card containing the "Welcome back / Sign in to your account" header, the Email and Password input fields with icons, the "Forgot password?" link, the "Sign In" button in the accent colour, and the "Don't have an account? Sign up" row at the bottom. Background should show the dark blue-to-teal gradient.

**Screenshot 2 — Register Screen**
Capture the Register screen with the same TruthLens logo at the top and the glass card containing the registration form fields: Name, Email, Password, and Confirm Password. The "Create Account" button and "Already have an account? Sign in" link should be visible.

**Screenshot 3 — Home Screen — News Feed Tab (Tab 1)**
Capture the main home screen with the bottom navigation bar visible, showing the "News" tab as active. The news feed should display a list of article cards each containing the article headline, source name, publication date, and a credibility badge/indicator. The floating action button or article analysis entry point should also be visible.

**Screenshot 4 — Article Details Screen**
Capture the article details view after tapping a news card. This should show the full article content, the AI credibility score displayed as a gauge or badge (0–100), the classification label (Likely True / Uncertain / Likely False), and the AI-generated natural-language summary below the article metadata.

**Screenshot 5 — Search / Explore Screen (Tab 2)**
Capture the Search screen showing the search bar at the top with a placeholder prompt, and the results list below it populated with matching article cards. The screen should have the dark background and the bottom nav bar visible with "Explore" tab active.

**Screenshot 6 — Digest Screen (Tab 3)**
Capture the Digest screen showing the personalised news digest dashboard. This should display categorised news sections or a curated feed with article cards, headlines, and credibility indicators, all on the dark gradient background with the bottom nav bar showing "Digest" as active.

**Screenshot 7 — AI Chat Screen (Tab 4 — Chats List)**
Capture the Chats list screen showing previous conversation threads with the AI fact-checking assistant. Each thread should show the last message preview and timestamp.

**Screenshot 8 — AI Chat Conversation**
Capture an active chat conversation screen showing user message bubbles and AI response bubbles in the conversational interface. The screen should show a question about a news topic and the AI's fact-checked response with source references.

**Screenshot 9 — Profile Screen (Tab 5)**
Capture the Profile screen showing the user's avatar, display name, and account details at the top, followed by the settings menu list including: Edit Profile, Reading History, Categories, Language, Privacy & Security, Manage Devices, Subscription, Help & Support, About, and the Log Out button at the bottom. Dark themed with glassmorphism card sections.

**Screenshot 10 — Edit Profile Screen**
Capture the Edit Profile screen showing the editable fields for name, bio, and profile photo upload option. The "Save Changes" button should be visible.

**Screenshot 11 — Chess Game — Board View**
Capture the Chess game screen during an active game, showing the full 8×8 chess board with pieces rendered using Unicode chess symbols (♔♛♟ etc.), with a selected piece highlighted in yellow/amber and the current player's turn shown in the header. The move history panel should be visible at the bottom.

**Screenshot 12 — Chess Game — Game Over Dialog**
Capture the Victory or Defeat dialog overlay — the glassmorphism dialog with backdrop blur, the gold trophy icon (for Victory) or red sad icon (for Defeat), the "Congratulations! You Won!" / "Game Over" text, and the "Play Again" and "Exit" buttons.

**Screenshot 13 — Fact vs Fiction Game**
Capture the Fact vs Fiction game screen mid-game, showing the Stats Bar at the top (Score, Streak, Timer countdown), the progress bar, the news headline card in the centre, and the two answer buttons — green "FACT" and red "FICTION" — at the bottom.

**Screenshot 14 — Fact vs Fiction — Answer Feedback**
Capture the moment after answering, showing the feedback card within the headline card: the green tick "Correct!" or red cross "Wrong!" indicator and the plain-English explanation text below it.

**Screenshot 15 — News Quiz Challenge**
Capture the News Quiz screen showing a multiple-choice question (e.g., "What does 'misinformation' mean?") with four answer options (A, B, C, D) displayed as cards. The progress bar and score should be visible in the header.

**Screenshot 16 — News Quiz — Results Screen**
Capture the Quiz results/game-over screen showing the trophy icon, the performance message (e.g., "Great Job! 🎉"), the score (e.g., 60/80), the percentage accuracy, and the correct/wrong count stats, with the "Play Again" and "Back to Profile" buttons.

---

### 7.4 Challenges Encountered and Solutions

- AI Model Performance
  Initial BERT model inference was slow (>5 seconds per request) on a standard VPS. This was resolved by switching to the lighter DistilBERT variant, which retains approximately 97% of BERT's accuracy at roughly half the inference latency, and by processing analysis requests through Laravel's async job queue to avoid blocking the main API thread.

- Cross-Platform Authentication
  Google Sign-In required separate OAuth client IDs for Android and iOS. This was resolved by configuring distinct OAuth clients for each platform in the Google Cloud Console and referencing both in the Flutter `google_sign_in` configuration.

- State Management Race Conditions
  Riverpod providers occasionally produced stale state during multi-screen navigation flows. This was resolved by refactoring affected providers to use the `AsyncNotifier` pattern with proper state invalidation triggered on navigation events.

- CORS Configuration
  Early integration testing revealed CORS policy issues between the Flutter web build and the Laravel API. This was resolved by configuring strict CORS middleware in Laravel with a precise origin allowlist, rejecting all unauthorised cross-origin requests.

---

### 7.5 Current System Limitations

- Multilingual support is partially implemented. The English locale is fully functional; Sinhala and Tamil translations require completion of the ARB localisation files and RTL layout adjustments.

- The news digest feature currently aggregates from a limited set of RSS feeds. A more robust and configurable news source management system is planned for the final phase.

- The Fact vs Fiction quiz leaderboard is not yet publicly accessible. The backend endpoint exists but the Flutter leaderboard screen is pending final integration and ranking logic.

- Full-text article search is implemented at the API level but the Flutter search UI and filter options require further development before the feature is release-ready.

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
- **Cross-Platform Auth** — Google Sign-In required different OAuth client IDs for Android and iOS. Resolved by configuring separate OAuth clients per platform in Google Cloud Console.
- **Race Conditions in State** — Riverpod providers occasionally produced stale state in multi-screen navigation flows. Resolved by refactoring to the `AsyncNotifier` pattern with proper invalidation on navigation events.
- **CORS Configuration** — Early testing revealed CORS policy issues between Flutter web build and Laravel API. Resolved by configuring strict CORS middleware with a proper origin allowlist in Laravel.

---

### 8.3 Future Work

The following work remains to bring TruthLens to full project completion:

1. **Complete multilingual support** — Implement full Sinhala and Tamil translations using the `intl` package and ARB files.
2. **Implement real-time features** — Explore lightweight polling or WebSocket approach via Laravel Echo/Pusher for messaging and live notifications using the existing MySQL backend.
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

- **State Management** — Flutter Riverpod 2.x
- **Version Control** — Git / GitHub
- **Deployment Target** — DigitalOcean / Fly.io + Docker

---

_© 2026 – Student ID: 10953371 – Yashira De Silva – PUSL3190 Computing Project – All rights reserved._
