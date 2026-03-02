# TruthLens – System Diagrams

> **Project:** TruthLens – AI-Powered Misinformation Detection Platform
> **Student:** Yashira De Silva | **ID:** 10953371
> **Module:** PUSL3190 Computing Project

This file contains all **Mermaid diagram source code** for the TruthLens system.
You can paste any of the code blocks below into a Mermaid-compatible renderer to generate the diagram:

- 🌐 **[Mermaid Live Editor](https://mermaid.live)** – paste code directly to render and export
- ✍️ **VS Code** – install the _Markdown Preview Mermaid Support_ extension
- 📄 **GitHub** – Mermaid is natively rendered in `.md` files

---

## Table of Contents

1. [System Architecture Diagram](#1-system-architecture-diagram)
2. [Use Case Diagram](#2-use-case-diagram)
3. [Class Diagram](#3-class-diagram)
4. [Entity-Relationship (ER) Diagram](#4-entity-relationship-er-diagram)
5. [Activity Diagram – Article Analysis](#5-activity-diagram--article-analysis)
6. [Sequence Diagram – User Login](#6-sequence-diagram--user-login)
7. [Sequence Diagram – Article Credibility Analysis](#7-sequence-diagram--article-credibility-analysis)
8. [Sequence Diagram – AI Chat](#8-sequence-diagram--ai-chat)
9. [State Diagram – Authentication State](#9-state-diagram--authentication-state)
10. [Project Timeline (Gantt Chart)](#10-project-timeline-gantt-chart)

---

## 1. System Architecture Diagram

This diagram illustrates the high-level multi-tier architecture of TruthLens.

```mermaid
graph TB
    subgraph Mobile["📱 Flutter Mobile App (Android / iOS)"]
        A[Auth Screens]
        B[News Digest]
        C[Article Analysis]
        D[AI Chat]
        E[Bookmarks]
        F[Quiz / Game]
        G[Profile & Settings]
    end

    subgraph Backend["⚙️ Laravel 12 Backend API (PHP 8.2+)"]
        H[Auth Controller]
        I[Article Controller]
        J[Chat Controller]
        K[Bookmark Controller]
        L[Game Controller]
        M[JWT Middleware]
    end

    subgraph AI["🤖 FastAPI AI Microservice (Python 3.11+)"]
        N[BERT NLP Model]
        O[DistilBERT Inference]
        P[Credibility Scorer]
    end

    subgraph DB["🗄️ Data Layer"]
        Q[(MySQL 8.0\nUsers, Articles,\nBookmarks, Chat,\nBadges, Results)]
        S[(Redis Cache\nAPI Response Cache)]
    end

    subgraph External["🌐 External Services"]
        T[OpenAI GPT-4 /\nGoogle Gemini API]
        U[News RSS/API\nAggregators]
        V[Google OAuth\nFederated Identity]
    end

    Mobile -->|HTTPS REST JSON| Backend
    Backend -->|HTTP Internal| AI
    Backend -->|Eloquent ORM| Q
    Backend -->|Cache R/W| S
    Backend -->|HTTP Proxy| T
    Backend -->|Fetch News| U
    Backend -->|OAuth Callback| V
    AI -->|Score + Summary| Backend
```

---

## 2. Use Case Diagram

This diagram shows all system actors and use cases.

```mermaid
graph LR
    GU(["👤 Guest User"])
    RU(["👤 Registered User"])
    AI_SYS(["🤖 AI System"])
    ADMIN(["🛡️ Administrator"])

    GU --> UC1[View Public News Feed]
    GU --> UC2[Register Account]
    GU --> UC3[Login]

    RU --> UC3
    RU --> UC4[Login with Google OAuth]
    RU --> UC5[Submit Article for Analysis]
    RU --> UC6[Browse Personalised News Digest]
    RU --> UC7[Use AI Fact-Checking Chat]
    RU --> UC8[Bookmark Articles]
    RU --> UC9[Search News & Fact-Checks]
    RU --> UC10[Play Fact vs Fiction Quiz]
    RU --> UC11[View Badges & Leaderboard]
    RU --> UC12[View & Update Profile]
    RU --> UC13[Switch Language EN/SI/TA]
    RU --> UC14[View Article Discussion Threads]

    UC5 -->|triggers| AI_SYS
    AI_SYS --> UC15[Analyse Article Credibility via BERT]
    AI_SYS --> UC16[Generate Credibility Score]
    AI_SYS --> UC17[Return NLP Summary]

    ADMIN --> UC18[Manage Users]
    ADMIN --> UC19[Moderate Content]
```

---

## 3. Class Diagram

This diagram shows the core domain classes and their relationships.

```mermaid
classDiagram
    class User {
        +int id
        +string name
        +string email
        +string password_hash
        +string google_id
        +string locale
        +int points
        +datetime created_at
        +register()
        +login()
        +logout()
        +updateProfile()
        +getPoints()
    }

    class Article {
        +int id
        +string url
        +string title
        +text body
        +string source
        +datetime published_at
        +float cached_score
        +analyse()
        +bookmark()
    }

    class AnalysisResult {
        +int id
        +int user_id
        +int article_id
        +float credibility_score
        +string classification
        +text summary
        +datetime created_at
        +getScore()
        +getSummary()
    }

    class Bookmark {
        +int id
        +int user_id
        +int article_id
        +datetime created_at
        +save()
        +remove()
    }

    class ChatSession {
        +int id
        +int user_id
        +datetime created_at
        +sendMessage()
        +getHistory()
    }

    class ChatMessage {
        +int id
        +int session_id
        +string role
        +text content
        +datetime created_at
    }

    class QuizAttempt {
        +int id
        +int user_id
        +int score
        +int total_questions
        +datetime completed_at
        +start()
        +submitAnswer()
        +getScore()
    }

    class Badge {
        +int id
        +string name
        +string description
        +string icon_url
        +json criteria
        +award()
        +check()
    }

    class UserBadge {
        +int user_id
        +int badge_id
        +datetime awarded_at
    }

    User "1" --> "0..*" AnalysisResult : submits
    User "1" --> "0..*" Bookmark : saves
    User "1" --> "0..*" ChatSession : starts
    User "1" --> "0..*" QuizAttempt : plays
    User "1" --> "0..*" UserBadge : earns
    ChatSession "1" --> "1..*" ChatMessage : contains
    Article "1" --> "0..*" AnalysisResult : has
    Article "1" --> "0..*" Bookmark : referenced_in
    Badge "1" --> "0..*" UserBadge : assigned_via
```

---

## 4. Entity-Relationship (ER) Diagram

This diagram shows the relational database schema.

```mermaid
erDiagram
    USERS {
        int id PK
        string name
        string email UK
        string password_hash
        string google_id
        string locale
        int points
        timestamp created_at
        timestamp updated_at
    }

    ARTICLES {
        int id PK
        string url UK
        string title
        text body
        string source
        float cached_score
        timestamp published_at
        timestamp created_at
    }

    ANALYSIS_RESULTS {
        int id PK
        int user_id FK
        int article_id FK
        float credibility_score
        string classification
        text summary
        timestamp created_at
    }

    BOOKMARKS {
        int id PK
        int user_id FK
        int article_id FK
        timestamp created_at
    }

    CHAT_SESSIONS {
        int id PK
        int user_id FK
        timestamp created_at
    }

    CHAT_MESSAGES {
        int id PK
        int session_id FK
        string role
        text content
        timestamp created_at
    }

    QUIZ_ATTEMPTS {
        int id PK
        int user_id FK
        int score
        int total_questions
        timestamp completed_at
    }

    BADGES {
        int id PK
        string name
        string description
        string icon_url
        json criteria
    }

    USER_BADGES {
        int user_id FK
        int badge_id FK
        timestamp awarded_at
    }

    USERS ||--o{ ANALYSIS_RESULTS : submits
    USERS ||--o{ BOOKMARKS : saves
    USERS ||--o{ CHAT_SESSIONS : starts
    USERS ||--o{ QUIZ_ATTEMPTS : plays
    USERS ||--o{ USER_BADGES : earns
    ARTICLES ||--o{ ANALYSIS_RESULTS : analysed_in
    ARTICLES ||--o{ BOOKMARKS : referenced_in
    CHAT_SESSIONS ||--|{ CHAT_MESSAGES : contains
    BADGES ||--o{ USER_BADGES : awarded_via
```

---

## 5. Activity Diagram – Article Analysis

This diagram shows the flow when a user submits an article for credibility analysis.

```mermaid
flowchart TD
    Start([🚀 User Submits Article])
    Start --> Validate{Input Valid?\nURL or Text?}
    Validate -- No --> Error1([❌ Return Validation Error])
    Validate -- Yes --> CheckCache{Cached Result\nExists?}
    CheckCache -- Yes --> ReturnCached([✅ Return Cached\nCredibility Score])
    CheckCache -- No --> ForwardFastAPI[Forward to\nFastAPI AI Service]
    ForwardFastAPI --> LoadModel[Load BERT/DistilBERT\nNLP Model]
    LoadModel --> Tokenise[Tokenise\nArticle Content]
    Tokenise --> Inference[Run Model\nInference]
    Inference --> Score[Generate\nCredibility Score 0-100]
    Score --> Classify{Classification}
    Classify -- Score ≥ 70 --> LikelyTrue[🟢 Likely True]
    Classify -- Score 40-69 --> Uncertain[🟡 Uncertain / Unverified]
    Classify -- Score < 40 --> LikelyFalse[🔴 Likely False]
    LikelyTrue --> GenSummary[Generate\nNLP Summary]
    Uncertain --> GenSummary
    LikelyFalse --> GenSummary
    GenSummary --> SaveDB[(Save to\nMySQL Database)]
    SaveDB --> ReturnResult([✅ Return Score +\nSummary to App])
```

---

## 6. Sequence Diagram – User Login

This diagram shows the authentication flow for email/password login.

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as Laravel API
    participant DB as MySQL Database

    User->>App: Enter email + password
    App->>App: Validate input fields
    App->>API: POST /api/auth/login\n{email, password}
    API->>DB: SELECT user WHERE email = ?
    DB-->>API: User record
    API->>API: bcrypt.verify(password, hash)

    alt Credentials Valid
        API->>API: Generate JWT token
        API-->>App: 200 OK {token, user_data}
        App->>App: Store JWT in\nflutter_secure_storage
        App-->>User: Navigate to Home Screen
    else Credentials Invalid
        API-->>App: 401 Unauthorized\n{message: "Invalid credentials"}
        App-->>User: Show error snackbar
    end
```

---

## 7. Sequence Diagram – Article Credibility Analysis

This diagram shows the full pipeline from article submission to result display.

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as Laravel API
    participant Cache as Redis Cache
    participant FastAPI as FastAPI AI Service
    participant DB as MySQL

    User->>App: Submit article URL or text
    App->>API: POST /api/articles/analyse\n{url OR text}\nAuthorization: Bearer JWT

    API->>API: Validate JWT token
    API->>Cache: Check cache for URL hash

    alt Cache Hit
        Cache-->>API: Cached credibility result
        API-->>App: 200 OK {score, classification, summary}
    else Cache Miss
        API->>FastAPI: POST /analyse\n{text_content}
        FastAPI->>FastAPI: Tokenise text
        FastAPI->>FastAPI: BERT model inference
        FastAPI-->>API: {score, classification, summary}
        API->>DB: INSERT analysis_result
        API->>Cache: Cache result (TTL: 24h)
        API-->>App: 200 OK {score, classification, summary}
    end

    App-->>User: Display credibility gauge\n+ summary card
```

---

## 8. Sequence Diagram – AI Chat

This diagram shows the flow of a user message through the AI chat feature.

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as Laravel API
    participant DB as MySQL
    participant LLM as OpenAI GPT-4 / Gemini

    User->>App: Type and send message
    App->>API: POST /api/chat/message\n{session_id, message}\nAuthorization: Bearer JWT

    API->>DB: Load chat session history
    DB-->>API: Previous messages (context)

    API->>LLM: POST to LLM API\n{system_prompt + history + user_message}

    LLM-->>API: AI response with sources

    API->>DB: INSERT chat_message (user + AI)
    API-->>App: 200 OK {response, sources[]}

    App-->>User: Display AI response\nwith source references
```

---

## 9. State Diagram – Authentication State

This diagram shows all authentication states in the Flutter application.

```mermaid
stateDiagram-v2
    [*] --> Unauthenticated : App Launch

    Unauthenticated --> Loading : User Submits Credentials\n(Email/Password or Google OAuth)

    Loading --> Authenticated : JWT Token Received\n& Stored Securely

    Loading --> Unauthenticated : Authentication Failed\n(Invalid Credentials / Network Error)

    Authenticated --> TokenRefreshing : JWT Near Expiry\n(Auto Refresh)

    TokenRefreshing --> Authenticated : Token Refreshed Successfully

    TokenRefreshing --> Unauthenticated : Refresh Failed\n(Force Re-Login)

    Authenticated --> Unauthenticated : User Logs Out\n(Token Invalidated)

    Authenticated --> ProfileUpdate : User Updates Profile

    ProfileUpdate --> Authenticated : Update Saved

    note right of Authenticated
        User has full access to:
        - News Digest
        - Article Analysis
        - AI Chat
        - Bookmarks
        - Quiz / Game
        - Profile & Settings
    end note
```

---

## 10. Project Timeline (Gantt Chart)

This diagram shows the full project timeline from initiation to final submission.

```mermaid
gantt
    title TruthLens – PUSL3190 Project Timeline
    dateFormat  YYYY-MM-DD
    excludes    weekends

    section Phase 1: Initiation
    Requirements Gathering      :done,    p1a, 2025-09-01, 2025-09-21
    PID Document Submission     :done,    p1b, 2025-09-22, 2025-10-04

    section Phase 2: Design
    System Architecture Design  :done,    p2a, 2025-10-06, 2025-10-20
    Database Schema & UML       :done,    p2b, 2025-10-20, 2025-11-01
    UI Wireframes (Figma)       :done,    p2c, 2025-10-13, 2025-11-01

    section Phase 3: Backend
    Laravel Project Setup       :done,    p3a, 2025-11-03, 2025-11-10
    JWT Auth & User API         :done,    p3b, 2025-11-10, 2025-11-21
    Google OAuth Integration    :done,    p3c, 2025-11-21, 2025-11-28
    Article Analysis API        :done,    p3d, 2025-11-28, 2025-12-12
    Bookmarks & Chat API        :done,    p3e, 2025-12-12, 2025-12-22

    section Phase 4: AI Service
    FastAPI Setup               :done,    p4a, 2025-12-01, 2025-12-08
    BERT Model Integration      :done,    p4b, 2025-12-08, 2025-12-19
    Inference Optimisation      :done,    p4c, 2025-12-19, 2026-01-05

    section Phase 5: Frontend
    Flutter Project Setup       :done,    p5a, 2026-01-06, 2026-01-13
    Auth Screens                :done,    p5b, 2026-01-13, 2026-01-24
    News Digest & Article UI    :done,    p5c, 2026-01-24, 2026-02-07
    AI Chat & Bookmarks UI      :done,    p5d, 2026-02-07, 2026-02-21
    Profile & Theme             :done,    p5e, 2026-02-21, 2026-02-28

    section Phase 6: Features
    Quiz / Game Screen          :active,  p6a, 2026-02-28, 2026-03-14
    Multilingual Support        :active,  p6b, 2026-03-01, 2026-03-14
    SQL Query Optimisation      :active,  p6c, 2026-03-01, 2026-03-21
    Search Feature              :         p6d, 2026-03-14, 2026-03-28

    section Phase 7: Testing
    Unit & Integration Tests    :         p7a, 2026-03-21, 2026-04-04
    User Acceptance Testing     :         p7b, 2026-04-04, 2026-04-11

    section Phase 8: Submission
    Final Report Writing        :         p8a, 2026-04-07, 2026-04-18
    Presentation Preparation    :         p8b, 2026-04-14, 2026-04-21
    Final Submission            :milestone, p8c, 2026-04-22, 0d
```

---

## How to Render These Diagrams

### Option 1: Mermaid Live Editor (Recommended)

1. Go to **[mermaid.live](https://mermaid.live)**
2. Paste the code block content (without the triple backticks)
3. Click **"Export"** to download as SVG or PNG

### Option 2: VS Code

1. Install extension: **"Markdown Preview Mermaid Support"** (by Matt Bierner)
2. Open this `.md` file
3. Press `Cmd+Shift+V` (Mac) to open Markdown Preview
4. Diagrams render inline automatically

### Option 3: GitHub

- Mermaid diagrams in `.md` files are **rendered natively** on GitHub
- Simply push this file to your repository and view it on GitHub.com

### Option 4: Pandoc + PDF Export

```bash
# Install mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export individual diagram from a file
mmdc -i diagram.mmd -o diagram.png

# Generate PDF from markdown with mermaid
pandoc DIAGRAMS_README.md -o diagrams.pdf
```

---

_© 2026 – Student ID: 10953371 – Yashira De Silva – PUSL3190 Computing Project_
