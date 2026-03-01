# TruthLens – Interim Report

> **Student ID:** 10953371  
> **Project:** TruthLens – AI-Powered Misinformation Detection Platform  
> **Date:** February 2026

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
  - [3.4 Networking Requirements](#34-networking-requirements-optional)
- [Chapter 04 – Feasibility Study](#chapter-04--feasibility-study)
  - [4.1 Operational Feasibility](#41-operational-feasibility)
  - [4.2 Economical Feasibility](#42-economical-feasibility)
  - [4.3 Technical Feasibility](#43-technical-feasibility)

---

## Chapter 01 – Introduction

### 1.1 Introduction

The exponential growth of social media and digital news platforms has made information more accessible than ever. However, this accessibility comes at a cost — the rapid, unchecked spread of misinformation, disinformation, and fake news poses a significant threat to public trust, democratic processes, and individual decision-making.

**TruthLens** is a cross-platform mobile application designed to combat this problem by leveraging Artificial Intelligence (AI) and Natural Language Processing (NLP) to help users identify and evaluate the credibility of news articles and online content in real time. The application provides users with AI-powered analysis tools, credibility scores, fact-checking features, and media literacy resources — all within an intuitive, accessible interface.

The system is built using **Flutter** (Dart) for the cross-platform mobile frontend and **Laravel 12** (PHP) for the RESTful backend API, with **JWT-based authentication** ensuring secure access. AI/ML capabilities are integrated through external API services to deliver content analysis and chat-based fact-checking.

---

### 1.2 Problem Definition

The modern information landscape presents the following core challenges:

1. **Volume and Speed:** Millions of news articles and social media posts are published daily, making manual fact-checking impossible at scale.
2. **Credibility Ambiguity:** Average users lack reliable tools to quickly assess the trustworthiness of a news source or article without extensive research.
3. **Misinformation Spread:** False or misleading content tends to spread faster than corrections, creating lasting public confusion on critical topics such as health, politics, and climate.
4. **Lack of Media Literacy:** Many users are not equipped with the skills or resources to critically evaluate the news they consume.
5. **Fragmented Tools:** Existing fact-checking resources are often website-based, require manual effort, and are not integrated into users' everyday mobile news consumption habits.

The core problem is therefore: **there is no widely accessible, AI-powered, mobile-first tool that provides real-time credibility analysis of news articles with an engaging, user-friendly experience.**

---

### 1.3 Project Objectives

The primary objectives of the TruthLens project are:

1. **Develop a cross-platform mobile application** (iOS and Android) using Flutter that delivers a seamless, responsive, and engaging user experience.
2. **Implement AI-powered content analysis** to assess the credibility and potential bias of news articles provided by users via URL or text input.
3. **Provide a real-time AI chat assistant** that allows users to ask fact-checking questions and receive evidence-based, sourced responses.
4. **Offer a personalised news digest** that aggregates news from multiple sources, filtered and ranked by credibility.
5. **Enable article bookmarking and search** so users can save, revisit, and share credible content.
6. **Build a secure, scalable backend API** using Laravel with JWT authentication to manage user accounts, preferences, and data.
7. **Incorporate educational and gamification elements** (e.g., a media literacy quiz/game) to engage users and improve digital literacy.
8. **Support multilingual localisation** to make the platform accessible to a broader audience.

---

## Chapter 02 – System Analysis

### 2.1 Facts Gathering Techniques

The following techniques were used to understand requirements and inform the system design:

| Technique                          | Details                                                                                                                                            |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Literature Review**              | Reviewed academic papers on fake news detection, NLP-based credibility scoring, and media literacy frameworks.                                     |
| **Existing System Analysis**       | Evaluated existing tools such as Snopes, FactCheck.org, NewsGuard, and Google Fact Check Tools to identify gaps.                                   |
| **User Surveys**                   | Conducted informal surveys among target users (university students and young professionals) to understand news consumption habits and pain points. |
| **Prototype Walkthroughs**         | Created early wireframes and gathered feedback on usability and feature priorities.                                                                |
| **Technical Documentation Review** | Studied documentation for Flutter, Laravel, JWT authentication, and AI/NLP API services to assess feasibility.                                     |
| **Industry Reports**               | Referenced reports from Reuters Institute for the Study of Journalism and MIT Media Lab on misinformation trends.                                  |

---

### 2.2 Existing System

Several tools currently address the fake news and misinformation problem to varying degrees:

| System                      | Description                                                                                                        | Type                   |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------- |
| **Snopes**                  | One of the oldest and most respected fact-checking websites. Covers viral claims, urban legends, and news stories. | Web-based, manual      |
| **FactCheck.org**           | Nonpartisan fact-checking site focusing on political claims and statements by public figures.                      | Web-based, manual      |
| **NewsGuard**               | Browser extension that rates news websites for credibility using human analysts.                                   | Browser extension      |
| **Google Fact Check Tools** | Aggregates fact checks from publishers and displays them in search results.                                        | Search-integrated      |
| **PolitiFact**              | Focuses on U.S. political claims, using a "Truth-O-Meter" rating scale.                                            | Web-based, manual      |
| **ClaimBuster**             | AI-assisted tool for identifying check-worthy factual claims in text.                                              | Web-based, AI-assisted |

---

### 2.3 Drawbacks of the Existing System

Despite the availability of the tools above, significant limitations remain:

1. **Not Mobile-First:** Most existing tools are websites or browser extensions, with limited or no dedicated mobile application experience optimised for on-the-go use.
2. **Manual & Slow:** The most authoritative fact-checking services (Snopes, FactCheck.org, PolitiFact) rely on human analysts, meaning coverage is limited and verification can take days.
3. **Narrow Scope:** Existing AI tools (e.g., ClaimBuster) focus on narrow tasks such as claim detection, without providing a full-pipeline solution including credibility scoring, source analysis, and user guidance.
4. **No Personalisation:** None of the existing tools offer personalised news digests, user history tracking, or adaptive recommendations based on individual reading habits.
5. **No Interactive Learning:** Existing tools are passive information sources. There is no gamification, quiz, or interactive educational component to actively build media literacy skills.
6. **No Integrated Chat:** Users cannot ask follow-up questions or engage in a dialogue about a specific article's credibility — they receive a verdict with limited explanation.
7. **Language Limitations:** Most tools are English-only, restricting accessibility for non-English-speaking users.
8. **No Bookmarking / Unified Workflow:** Users cannot save articles for later review or manage a credibility-verified reading list from a single application.

---

## Chapter 03 – Requirements Specification

### 3.1 Functional Requirements

The following functional requirements describe what the TruthLens system must do:

#### Authentication & User Management

- **FR-01:** Users must be able to register a new account using an email address and password.
- **FR-02:** Users must be able to log in and receive a secure JWT access token.
- **FR-03:** Users must be able to log in using Google OAuth (via Google Sign-In).
- **FR-04:** Users must be able to view and update their profile information.
- **FR-05:** Users must be able to securely log out, invalidating their active token.

#### News & Article Analysis

- **FR-06:** Users must be able to submit a news article URL or text for AI-powered credibility analysis.
- **FR-07:** The system must return a credibility score and a summary of the analysis results.
- **FR-08:** Users must be able to browse a curated news digest aggregated from multiple sources.
- **FR-09:** Users must be able to search for news articles by keyword or topic.

#### AI Chat Assistant

- **FR-10:** Users must be able to engage in a real-time conversational AI chat to ask fact-checking questions.
- **FR-11:** The AI assistant must provide sourced, evidence-based responses.

#### Bookmarks

- **FR-12:** Users must be able to bookmark articles for later reading.
- **FR-13:** Users must be able to view and manage their list of bookmarked articles.

#### Gamification / Media Literacy

- **FR-14:** The application must include an interactive game or quiz to educate users on identifying misinformation.

#### Localisation

- **FR-15:** The application must support multiple languages via Flutter's localisation framework.

---

### 3.2 Non-Functional Requirements

| ID         | Category        | Requirement                                                                                                   |
| ---------- | --------------- | ------------------------------------------------------------------------------------------------------------- |
| **NFR-01** | Performance     | API responses must be returned within 2 seconds under normal network conditions.                              |
| **NFR-02** | Scalability     | The backend must be designed to support horizontal scaling to accommodate growing user demand.                |
| **NFR-03** | Security        | All API endpoints must be protected with JWT authentication. Passwords must be hashed using bcrypt.           |
| **NFR-04** | Usability       | The mobile UI must follow Material Design guidelines and be accessible to users with no technical background. |
| **NFR-05** | Availability    | The backend API must target 99.5% uptime.                                                                     |
| **NFR-06** | Maintainability | Code must follow PSR-12 (PHP) and Dart/Flutter style guidelines; components must be modular and documented.   |
| **NFR-07** | Portability     | The Flutter frontend must run natively on both Android (API 21+) and iOS (12+).                               |
| **NFR-08** | Privacy         | User data must be stored securely; no personally identifiable information (PII) should be logged or exposed.  |

---

### 3.3 Hardware / Software Requirements

#### Development Environment

| Component            | Requirement                             |
| -------------------- | --------------------------------------- |
| **Operating System** | macOS 12+ / Windows 10+ / Ubuntu 20.04+ |
| **RAM**              | Minimum 8 GB (16 GB recommended)        |
| **Storage**          | Minimum 20 GB free disk space           |
| **CPU**              | Intel Core i5 / Apple M1 or equivalent  |

#### Software Requirements

| Component                  | Technology / Version                     |
| -------------------------- | ---------------------------------------- |
| **Frontend Framework**     | Flutter SDK (Dart)                       |
| **Backend Framework**      | Laravel 12 (PHP ≥ 8.2)                   |
| **Database**               | MySQL 8.0+                               |
| **Authentication**         | tymon/jwt-auth 2.x                       |
| **Social Auth**            | Laravel Socialite 5.x / Google Sign-In   |
| **State Management**       | Flutter Riverpod 2.x                     |
| **HTTP Client**            | Dart `http` package                      |
| **Version Control**        | Git / GitHub                             |
| **Package Manager (PHP)**  | Composer                                 |
| **Package Manager (Dart)** | pub (Flutter)                            |
| **IDE**                    | VS Code / Android Studio / IntelliJ IDEA |
| **API Testing**            | Postman / Insomnia                       |
| **Android Emulator**       | Android Studio AVD (API 21+)             |
| **iOS Simulator**          | Xcode (macOS only)                       |

#### Runtime / Deployment Requirements

| Component           | Requirement                   |
| ------------------- | ----------------------------- |
| **Web Server**      | Apache / Nginx with PHP-FPM   |
| **PHP**             | ≥ 8.2                         |
| **MySQL**           | 8.0+                          |
| **SSL Certificate** | Required for production HTTPS |
| **Mobile Device**   | Android 5.0+ or iOS 12+       |

---

### 3.4 Networking Requirements _(Optional)_

| Requirement               | Detail                                                                                                                 |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **API Protocol**          | RESTful HTTP/HTTPS API                                                                                                 |
| **Data Format**           | JSON                                                                                                                   |
| **Authentication Header** | `Authorization: Bearer <JWT>` on all protected endpoints                                                               |
| **Internet Connectivity** | The mobile application requires an active internet connection for article analysis, AI chat, and news digest features. |
| **API Base URL**          | Configurable via environment variable (`API_BASE_URL`)                                                                 |
| **CORS Policy**           | Backend must enforce strict CORS rules, permitting only authorised origins                                             |
| **Rate Limiting**         | API endpoints should implement rate limiting to prevent abuse (recommended: 60 requests/minute per user)               |
| **Ports**                 | Backend: Port 8000 (development), Port 443 (production HTTPS)                                                          |

---

## Chapter 04 – Feasibility Study

### 4.1 Operational Feasibility

TruthLens is operationally feasible for the following reasons:

- **User Demand:** There is a clear and growing public need for accessible misinformation detection tools, particularly on mobile platforms. Media literacy initiatives globally underscore this demand.
- **Ease of Use:** The Flutter-based interface is designed to be intuitive for non-technical users, minimising the learning curve. Onboarding flows, clear navigation, and familiar Material Design patterns ensure accessibility.
- **Automated Operations:** Core functionality — article analysis, credibility scoring, and AI chat — is automated via AI/ML APIs, reducing reliance on manual human effort and enabling 24/7 operation.
- **User Adoption:** The integration of gamification (media literacy quiz) and personalised news digests encourages habitual engagement and long-term user retention.
- **Maintainability:** The modular codebase (Laravel MVC backend, feature-based Flutter architecture) is designed for straightforward maintenance and onboarding of new developers.

> **Conclusion:** The system is operationally feasible. It addresses a well-defined real-world need, requires no specialist hardware from the end user, and can be operated with minimal ongoing human oversight.

---

### 4.2 Economical Feasibility

| Cost Category              | Estimated Cost                  | Notes                                              |
| -------------------------- | ------------------------------- | -------------------------------------------------- |
| **Development Labour**     | £0 (academic project)           | Developed by student contributor                   |
| **Backend Hosting**        | £5–£20/month                    | Shared hosting or VPS (e.g., DigitalOcean, Linode) |
| **Database (MySQL)**       | £0–£10/month                    | Included with most hosting plans                   |
| **AI / NLP API**           | £0–£50/month                    | Free tiers available (e.g., OpenAI, Google Gemini) |
| **Domain Name**            | ~£10/year                       | One-time/annual cost                               |
| **SSL Certificate**        | £0                              | Let's Encrypt (free)                               |
| **App Store Distribution** | £25 (Google) / £99/year (Apple) | One-time / annual                                  |
| **Total Estimated (MVP)**  | ~£40–£180/month                 | Highly scalable based on usage                     |

**Projected Benefits:**

- Potential for monetisation through a freemium model (premium AI analysis credits, ad-free experience).
- Significant social value through improved digital literacy and reduced misinformation impact.
- Low barrier to entry makes the project viable within academic and startup budgets.

> **Conclusion:** The project is economically feasible at both the development and operational stages. Open-source frameworks (Laravel, Flutter) eliminate licensing costs, and cloud hosting keeps operational costs manageable.

---

### 4.3 Technical Feasibility

| Dimension                     | Assessment                                                                                                                                                     |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Technology Maturity**       | All core technologies (Flutter, Laravel, MySQL, JWT) are mature, well-documented, and widely adopted in industry.                                              |
| **AI Integration**            | AI/NLP APIs (e.g., OpenAI GPT, Google Gemini) provide reliable, well-documented interfaces for content analysis and conversational AI.                         |
| **Cross-Platform Capability** | Flutter's single codebase targets Android, iOS, web, and desktop — maximising reach with minimal additional development effort.                                |
| **Security**                  | JWT authentication, bcrypt password hashing, HTTPS enforcement, and CORS policies provide a solid, industry-standard security baseline.                        |
| **Scalability**               | Laravel's queue system, caching layers, and support for cloud deployment (AWS, GCP, DigitalOcean) allow horizontal scaling as user numbers grow.               |
| **Developer Competence**      | The developer has demonstrated competency in both Flutter and Laravel, with existing backend API and frontend features already implemented.                    |
| **Third-Party Dependencies**  | External AI API availability and rate limits represent the primary technical risk; this is mitigated by designing the system to support multiple AI providers. |

> **Conclusion:** The project is technically feasible. The selected technology stack is proven, the development team has the requisite skills, and the architecture is designed to scale. The primary risk — AI API reliability — is manageable through appropriate abstraction and fallback strategies.

---

## Project Structure Overview

```
truth_lens/
├── apps/
│   ├── backend/               # Laravel 12 REST API
│   │   ├── app/
│   │   │   ├── Http/          # Controllers & Middleware
│   │   │   ├── Models/        # Eloquent models (User, etc.)
│   │   │   └── Providers/     # Service providers
│   │   ├── database/          # Migrations & seeders
│   │   ├── routes/            # API route definitions
│   │   └── .env.example       # Environment configuration template
│   │
│   └── frontend/              # Flutter cross-platform app
│       └── lib/
│           ├── features/
│           │   ├── auth/      # Login, register, Google OAuth
│           │   ├── news/      # News digest & article browsing
│           │   ├── article/   # Article credibility analysis
│           │   ├── chat/      # AI fact-checking chat
│           │   ├── bookmarks/ # Saved articles
│           │   ├── search/    # Content search
│           │   ├── game/      # Media literacy quiz/game
│           │   ├── profile/   # User profile management
│           │   └── digest/    # Personalised news digest
│           ├── core/          # Shared utilities, theme, constants
│           └── main.dart      # Application entry point
│
└── INTERIM_REPORT.md          # This document
```

---

## Tech Stack Summary

| Layer            | Technology                               |
| ---------------- | ---------------------------------------- |
| Mobile Frontend  | Flutter (Dart) + Riverpod                |
| Backend API      | Laravel 12 (PHP 8.2+)                    |
| Authentication   | JWT (tymon/jwt-auth) + Google OAuth      |
| Database         | MySQL 8.0+                               |
| AI / NLP         | External AI API (OpenAI / Google Gemini) |
| State Management | Flutter Riverpod 2.x                     |
| Version Control  | Git / GitHub                             |

---

_© 2026 – Student ID: 10953371 – All rights reserved._
