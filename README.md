# Kaarya AI, Intelligent Career Development Mobile Application

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Background of the Proposed Application](#2-background-of-the-proposed-application)
3. [Aims and Objectives](#3-aims-and-objectives)
4. [Features of the Application](#4-features-of-the-application)
5. [App Monetization and Business Model](#5-app-monetization-and-business-model)
6. [Similar Applications and Differentiation](#6-similar-applications-and-differentiation)
7. [Design Pattern and Architectural Pattern](#7-design-pattern-and-architectural-pattern)
8. [State Management](#8-state-management)
9. [Sensors and Third-Party APIs](#9-sensors-and-third-party-apis)
10. [Data and Security](#10-data-and-security)

---

## 1. Introduction

**Kaarya AI** is a cross-platform mobile application built with Flutter that transforms how job seekers, recruiters, colleges, and companies interact within the employment ecosystem. Rather than being a simple job board, Kaarya AI is an AI-powered career development platform that combines job discovery, AI-driven mock interviews with real-time voice conversation, resume building with intelligent suggestions, learning resources, real-time messaging, and a competitive leaderboard, all within a single, cohesive application.

The application serves three distinct user roles:

- **Candidates (Job Seekers):** Browse and apply for jobs, practice AI-powered voice interviews, build resumes with AI assistance, track applications, access learning resources, and compete on leaderboards.
- **Recruiters:** Post job listings with location tagging, manage applications, invite team members, and track job performance metrics.
- **Colleges:** Manage student cohorts, monitor student progress, share workspace resources, and facilitate career placement.

---

## 2. Background of the Proposed Application

The job market in Nepal and South Asia faces several systemic challenges. Fresh graduates often lack interview experience, leading to anxiety and poor performance in real interviews. Traditional job portals provide no feedback mechanism, candidates apply and wait, with no way to improve their skills. Recruiters struggle to find qualified candidates from specific institutions, and colleges have limited visibility into their students' career journeys after graduation.

Kaarya AI was conceived to address these interconnected problems. The core insight is that career development is not just about finding job listings, it is about building the skills, confidence, and connections needed to succeed. By integrating AI interview practice (using conversational voice AI), intelligent resume building, structured learning resources, and real-time communication into a unified platform, Kaarya AI creates a complete career development ecosystem rather than a fragmented collection of tools.

The application is built as a mobile-first experience because the target demographic, students, fresh graduates, and early-career professionals, predominantly access digital services through smartphones. Flutter was chosen as the development framework to ensure a native-quality experience on both Android and iOS from a single codebase.

---

## 3. Aims and Objectives

### Primary Aim

To develop an intelligent, AI-powered mobile application that streamlines and enhances the career development journey for job seekers while providing efficient tools for recruiters and educational institutions.

### Objectives

1. **Democratize Interview Preparation:** Provide AI-powered voice interview practice that simulates real interview scenarios, giving candidates unlimited practice opportunities with immediate, actionable feedback.
2. **Intelligent Resume Building:** Offer AI-assisted resume creation with ATS (Applicant Tracking System) scanning, AI-generated professional summaries, and experience bullet point suggestions.
3. **Unified Career Platform:** Combine job discovery, applications, interview preparation, resume building, learning resources, and professional communication into a single application, eliminating the need for multiple disconnected tools.
4. **Institutional Collaboration:** Enable colleges and companies to manage their communities, track progress, and facilitate career placement within the platform.
5. **Skill Development:** Provide structured learning resources (courses with chapters, difficulty levels, and progress tracking) to help candidates build marketable skills.
6. **Data-Driven Insights:** Deliver analytics on job performance, interview metrics, application summaries, and leaderboard rankings to help all stakeholders make informed decisions.

---

## 4. Features of the Application

### 4.1 Authentication and User Management

- **Multi-provider authentication:** Email/password registration and login, plus OAuth integration with Google and GitHub for one-tap sign-in.
- **Biometric login:** Fingerprint and face recognition support for returning users, with credentials encrypted in secure storage.
- **Password management:** Full password reset flow (request, verify OTP, confirm new password) and in-app password change.
- **Profile management:** Update personal details, upload professional certifications, and manage linked OAuth accounts.
- **Role-based access:** Distinct experiences for candidates, recruiters, and college administrators, with role-specific navigation and features.

### 4.2 Job Discovery and Management

- **Job listings:** Browse paginated job listings with detailed information including company details, location, requirements, and application deadlines.
- **Job creation (Recruiters):** Post new positions with rich text descriptions (HTML editor), location tagging via interactive map picker, and category selection.
- **Job metrics:** Recruiters can view performance analytics for each posting, total views, application counts, and engagement trends.
- **View tracking:** Every job view is recorded, providing recruiters with visibility into listing performance.

### 4.3 AI-Powered Interview System

This is the flagship feature of Kaarya AI. The interview system uses **VAPI (Voice AI Platform Integration)** to conduct real-time, voice-based mock interviews.

- **Voice conversation:** Real-time speech-to-text and text-to-speech powered by OpenAI and ElevenLabs, enabling natural conversational interviews.
- **Live transcription:** Both partial (in-progress) and final transcripts are displayed during the interview, so candidates can follow along.
- **Session management:** Start, complete, and review interview sessions with full transcript history.
- **AI feedback:** After completing a session, candidates receive detailed AI-generated feedback on their responses, communication skills, and areas for improvement.
- **Interview analytics:** Track performance trends across multiple sessions, identifying strengths and improvement areas over time.
- **Bookmarking:** Save interviews for later practice.

### 4.4 Application Tracking

- **Apply to jobs:** Submit applications directly through the app with resume attachment.
- **Application dashboard:** View all submitted applications with status tracking (pending, reviewed, shortlisted, rejected).
- **Application summary:** Aggregated statistics showing total applications, success rates, and activity trends.
- **Resume management:** Upload, manage, and track multiple resumes with activity monitoring for each document.

### 4.5 AI Resume Builder

- **Draft management:** Create, save, edit, and manage multiple resume drafts.
- **AI-powered content generation:**
  - **Professional summary:** Auto-generate a polished professional summary based on experience and skills.
  - **Experience bullets:** AI generates impactful bullet points for work experience entries.
  - **AI suggestions:** Get intelligent recommendations to improve resume content and formatting.
- **ATS scanning:** Analyze resumes against Applicant Tracking System criteria to ensure they pass automated screening.
- **PDF generation:** Export finalized resumes as professionally formatted PDF documents.
- **Save as resume:** Convert drafts into application-ready resumes stored in the user's resume library.

### 4.6 Learning Resources

- **Course catalogue:** Browse paginated courses with search functionality and difficulty-level filtering (beginner, intermediate, advanced).
- **Course management:** Admins and recruiters can create, update, and delete courses.
- **Chapter structure:** Courses contain structured chapters displayed in an accordion layout for organized learning.
- **Progress tracking:** Track completion progress through course chapters.

### 4.7 Real-Time Messaging (Inbox)

- **Stream Chat integration:** Full-featured real-time messaging powered by Stream Chat, supporting direct messages and group channels.
- **Channel management:** Automatic channel creation and management via the backend.
- **Video tokens:** Infrastructure for video communication through Stream's video SDK.

### 4.8 Bookmarks

- **Save jobs:** Bookmark job listings for later review and application.
- **Save interviews:** Bookmark interview templates for future practice sessions.
- **Unified bookmarks view:** Access all saved content from a single bookmarks page.

### 4.9 Leaderboard

- **Competitive ranking:** Candidates are ranked based on their activity, interview performance, and engagement metrics.
- **Community motivation:** Leaderboards encourage consistent platform usage and skill development.

### 4.10 Dashboard

- **Overview page:** A unified dashboard showing key metrics, recent jobs, upcoming interviews, application status, bookmarks, and leaderboard position.
- **Role-specific views:** Candidates see their career progress; recruiters see job performance; colleges see student engagement.

### 4.11 Company and College Workspaces

- **Company management:** Create and manage company profiles, invite recruiters via invitation codes, manage team members, and access dedicated workspaces.
- **College management:** Create and manage college profiles, invite and manage students, track cohort metrics, and facilitate career placement.
- **Join by code:** Users can join organizations using invitation codes, simplifying onboarding.

### 4.12 Onboarding

- **Guided setup:** New users are walked through profile completion and preference selection to personalize their experience.

### 4.13 Sensor-Driven Features

- **Shake-to-navigate:** Shaking the device on the dashboard opens the AI Interview Hub instantly, a physical gesture shortcut for the most-used feature.
- **Ambient light theme:** The app automatically adjusts between light and dark themes based on the ambient light sensor reading, providing comfortable viewing in any environment.
- **Proximity security:** If the proximity sensor detects the device has been covered for 5 continuous seconds, a logout confirmation dialog appears, a security feature that protects against unauthorized access when the phone is left unattended.

---

## 5. App Monetization and Business Model

Kaarya AI implements a **freemium subscription model** with Stripe payment integration, designed for sustainable revenue generation while maintaining accessibility.

### 5.1 Subscription Tiers

| Feature                       | Free Plan             | Pro Plan                           |
| ----------------------------- | --------------------- | ---------------------------------- |
| Job browsing and applications | Unlimited             | Unlimited                          |
| Resume uploads                | Limited               | Unlimited                          |
| AI interview sessions         | Limited monthly quota | Higher/unlimited monthly quota     |
| AI resume suggestions         | Basic                 | Full AI suite                      |
| ATS scanning                  | Not available         | Included                           |
| Learning resources            | Browse only           | Full access with progress tracking |
| Priority support              | Not available         | Included                           |

### 5.2 Payment Infrastructure

The billing system is fully integrated with **Stripe**, a globally trusted payment processor. The implementation includes:

- **Stripe Checkout Sessions:** Secure, hosted payment pages created via the backend API (`/payments/stripe/checkout-session`). Users are redirected to Stripe's checkout flow within an in-app WebView, ensuring PCI compliance without handling card details directly.
- **Session Verification:** After payment, the app verifies the transaction via `/payments/stripe/verify-session`, confirming plan activation and recording the invoice.
- **Customer Portal:** Returning subscribers can manage their subscription (cancel, change plan, update payment method) through Stripe's customer portal (`/payments/stripe/portal-session`).
- **Invoice Tracking:** Every transaction generates an invoice with a unique transaction UUID, amount in NPR (Nepali Rupees), payment provider, status, and timestamps, providing full financial transparency.
- **Billing Summary:** Users can view their current plan, next billing cycle, usage statistics (interviews used vs. remaining), and complete invoice history from the billing page.

### 5.3 Revenue Streams

1. **Subscription Revenue (Primary):** Monthly Pro plan subscriptions from candidates who want unlimited AI interviews, full resume AI features, and ATS scanning.
2. **Institutional Licensing (B2B):** Companies and colleges can purchase workspace plans to manage their communities, providing recurring institutional revenue.
3. **Premium Job Listings (Future):** Recruiters can pay for promoted/featured job listings to increase visibility.
4. **Certification and Assessment (Future):** Paid professional certifications and skill assessments that candidates can showcase to employers.

### 5.4 Business Model Viability

The freemium model is specifically chosen because:

- **Low barrier to entry:** Free tier attracts users; AI interview quality converts them to paid subscribers.
- **Network effects:** More candidates attract more recruiters, and more job listings attract more candidates, creating a self-reinforcing growth loop.
- **Recurring revenue:** Subscription model provides predictable monthly recurring revenue (MRR).
- **B2B expansion:** College and company workspaces create enterprise-level contracts with higher lifetime value.

---

## 6. Similar Applications and Differentiation

### 6.1 Existing Applications

| Application        | Description                           | Limitations                                                                                                  |
| ------------------ | ------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **LinkedIn**       | Professional networking and job board | No AI interview practice; resume builder is basic; no voice-based features; overwhelming for fresh graduates |
| **Indeed**         | Job search aggregator                 | Pure job listing, no skill development, no interview prep, no AI features                                    |
| **Glassdoor**      | Job search with company reviews       | Focused on company reviews, not candidate development; no AI interview or resume tools                       |
| **InterviewBuddy** | Video interview practice              | Interview-only tool, no job search, no resume building, no learning resources; not a unified platform        |
| **Pramp**          | Peer-to-peer mock interviews          | Requires scheduling with other users; no AI-powered on-demand practice; limited to tech interviews           |
| **Zety/Resume.io** | Online resume builders                | Resume-only, no job search, no interview prep, no analytics; standalone single-purpose tools                 |

### 6.2 How Kaarya AI Differs

1. **Unified Platform vs. Fragmented Tools:** While competitors each solve one piece of the career puzzle (LinkedIn for networking, Indeed for job search, InterviewBuddy for practice), Kaarya AI integrates all of these into a single application. A candidate can discover a job, practice for the interview with AI, build a tailored resume, and apply, all without leaving the app.

2. **AI Voice Interviews:** Unlike text-based chatbot interview tools, Kaarya AI uses real-time voice AI (VAPI with OpenAI and ElevenLabs) for natural conversational interviews. This is significantly closer to a real interview experience than typing answers to prompts.

3. **Intelligent Resume Suite:** The combination of AI-generated summaries, experience bullets, improvement suggestions, and ATS scanning in a single resume builder is not available in standalone job boards like Indeed or LinkedIn.

4. **Three-Sided Marketplace:** Kaarya AI serves candidates, recruiters, AND colleges simultaneously. This triangular relationship creates unique value, colleges can track student placement, recruiters can source from specific institutions, and candidates get institutional support alongside AI tools.

5. **Sensor-Enhanced UX:** No competing job platform uses device sensors for UX enhancement. Shake-to-navigate, ambient light theme adjustment, and proximity-based security are novel interactions that differentiate the user experience.

6. **Localized for Nepal/South Asia:** Pricing in NPR, local market understanding, and features designed for the South Asian graduate employment landscape, unlike global platforms that treat these markets as an afterthought.

7. **Gamification via Leaderboard:** The competitive leaderboard encourages consistent engagement and skill development, transforming passive job searching into active career building.

---

## 7. Design Pattern and Architectural Pattern

### 7.1 What is a Design Pattern?

A design pattern is a proven, reusable solution to a commonly occurring problem in software design. Design patterns are not finished code that can be copied directly; rather, they are templates and best practices that describe how to structure code to solve specific types of problems. They improve code readability, reduce coupling between components, and make systems easier to maintain and extend over time.

### 7.2 MVVM (Model-View-ViewModel) Design Pattern

Kaarya AI uses the **MVVM (Model-View-ViewModel)** design pattern throughout its presentation layer. MVVM was originally introduced by Microsoft for WPF applications but has become the dominant pattern for reactive UI frameworks, including Flutter with Riverpod.

**How MVVM works in Kaarya AI:**

```
┌─────────────────────────────────────────────────────┐
│                      VIEW                            │
│  (Flutter Widgets, Pages, Screens, UI Components)   │
│  Observes state changes, dispatches user actions      │
│                                                       │
│  Example: InterviewHubScreen, BillingPage,            │
│           ResourcesHubScreen, LoginPage               │
└──────────────┬──────────────────────▲────────────────┘
               │ User Actions         │ State Updates
               ▼                      │
┌─────────────────────────────────────────────────────┐
│                   VIEWMODEL                          │
│  (Riverpod Notifier<State> classes)                  │
│  Contains business logic, calls use cases,           │
│  updates state objects                               │
│                                                       │
│  Example: InterviewsViewModel, BillingViewModel,     │
│           AuthViewModel, DashboardViewModel           │
└──────────────┬──────────────────────▲────────────────┘
               │ Use Case Calls       │ Results (Either<Failure, T>)
               ▼                      │
┌─────────────────────────────────────────────────────┐
│                     MODEL                            │
│  (Entities, API Models, State classes)               │
│  Pure data representations, Equatable for           │
│  value equality, immutable, no business logic        │
│                                                       │
│  Example: InterviewEntity, BillingSummaryEntity,     │
│           JobEntity, InterviewsState                  │
└─────────────────────────────────────────────────────┘
```

**Concrete implementation in Kaarya AI:**

- **Model (State):** Each feature defines an immutable `FeatureState extends Equatable` class. For example, `InterviewsState` holds `isLoading`, `error`, `interviewsList`, and `selectedInterview`. State classes implement a `copyWith()` method using a special `_unset` sentinel value to correctly handle nullable fields, ensuring that explicitly passing `null` clears a value, while omitting a field preserves the current value:

  ```dart
  class InterviewsState extends Equatable {
    final bool isLoading;
    final String? error;
    final InterviewsSectionEntity? interviewsData;
    // ... more fields

    InterviewsState copyWith({
      bool? isLoading,
      Object? error = _unset,
      Object? interviewsData = _unset,
    }) { ... }
  }
  ```

- **View:** Flutter widgets that are `ConsumerWidget` or `ConsumerStatefulWidget` (Riverpod-aware). They use `ref.watch(viewModelProvider)` to reactively observe state and `ref.read(viewModelProvider.notifier).someMethod()` to dispatch actions. Views contain zero business logic, they only render UI based on current state and forward user interactions to the ViewModel:

  ```dart
  class InterviewHubScreen extends ConsumerWidget {
    Widget build(BuildContext context, WidgetRef ref) {
      final state = ref.watch(interviewsViewModelProvider);
      if (state.isLoading) return LoadingIndicator();
      if (state.error != null) return ErrorWidget(state.error!);
      return InterviewList(interviews: state.interviewsData);
    }
  }
  ```

- **ViewModel:** Riverpod `Notifier<FeatureState>` classes that encapsulate all business logic. They call domain-layer use cases, process results using `Either<Failure, T>` (from dartz), and update state accordingly. ViewModels never reference widgets or BuildContext:

  ```dart
  class InterviewsViewModel extends Notifier<InterviewsState> {
    InterviewsState build() => InterviewsState.initial();

    Future<void> getInterviewsList() async {
      state = state.copyWith(isLoading: true, error: null);
      final result = await ref.read(listInterviewsUseCaseProvider).call(...);
      result.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (data)    => state = state.copyWith(isLoading: false, interviewsData: data),
      );
    }
  }
  ```

**Why MVVM for Kaarya AI:**

1. **Separation of concerns:** UI rendering (View) is completely decoupled from business logic (ViewModel), which is decoupled from data representation (Model). A change in how data is displayed requires no change to how data is fetched or processed.
2. **Testability:** ViewModels can be unit-tested without any Flutter framework dependency. State transitions can be verified by calling ViewModel methods and asserting the resulting state, the test suite (using mocktail) validates this extensively.
3. **Reactive updates:** Riverpod's reactive system ensures that when the ViewModel updates state, all watching widgets automatically rebuild with the new data. No manual `setState()` calls, no callback chains, no event buses.
4. **Scalability:** With 15+ features, each with its own ViewModel and State, MVVM keeps each feature self-contained. Adding a new feature does not require touching existing ViewModels.

### 7.3 What is an Architectural Pattern?

An architectural pattern defines the high-level structural organization of an entire software system. While a design pattern (like MVVM) solves a specific problem within a layer, an architectural pattern determines how the layers themselves are organized, what responsibilities each layer has, and how data flows between them.

### 7.4 Clean Architecture

Kaarya AI implements **Clean Architecture** (inspired by Robert C. Martin / Uncle Bob), which organizes code into concentric layers with strict dependency rules. The fundamental principle is the **Dependency Rule**: source code dependencies can only point inward, outer layers depend on inner layers, never the reverse.

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│                    (Outermost Layer)                          │
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │   Pages/    │  │  ViewModels  │  │   State Classes  │    │
│  │  Screens    │  │  (Notifiers) │  │   (Equatable)    │    │
│  └─────────────┘  └──────┬───────┘  └──────────────────┘    │
│                          │ depends on                         │
├──────────────────────────▼──────────────────────────────────┤
│                      DOMAIN LAYER                            │
│                    (Innermost Layer)                          │
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │  Entities   │  │  Use Cases   │  │   Repository     │    │
│  │  (Pure      │  │  (Single     │  │   Interfaces     │    │
│  │   Dart)     │  │   purpose)   │  │   (Abstract)     │    │
│  └─────────────┘  └──────────────┘  └──────────────────┘    │
│                          ▲ depends on                         │
├──────────────────────────┤──────────────────────────────────┤
│                       DATA LAYER                             │
│                    (Outermost Layer)                          │
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐    │
│  │  API Models │  │ Data Sources │  │   Repository     │    │
│  │  (fromJson, │  │  (Remote +   │  │   Implementations│    │
│  │   toEntity) │  │   Local)     │  │   (Concrete)     │    │
│  └─────────────┘  └──────────────┘  └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

**Layer-by-layer breakdown as implemented in Kaarya AI:**

#### Domain Layer (Core Business Logic)

The domain layer is the heart of the application. It contains:

- **Entities** (`domain/entities/`): Pure Dart classes extending `Equatable` that represent core business objects. Entities have no knowledge of JSON, APIs, databases, or Flutter. For example, `InterviewEntity` contains fields like `id`, `title`, `description`, `difficulty`, `company`, pure data with value equality.

- **Repository Interfaces** (`domain/repositories/`): Abstract classes (e.g., `IInterviewsRepository`) that define what operations are available without specifying how they are performed. This is the key abstraction that enables the dependency inversion:

  ```dart
  abstract class IInterviewsRepository {
    Future<Either<Failure, InterviewsSectionEntity>> listInterviews(...);
    Future<Either<Failure, InterviewEntity>> getInterviewById(String id);
    Future<Either<Failure, InterviewSessionStartEntity>> startSession(...);
  }
  ```

- **Use Cases** (`domain/usecases/`): Single-responsibility classes, each representing one business operation. Every use case extends either `UseCaseWithParams<T, P>` or `UseCaseWithoutParams<T>` and has a corresponding Riverpod `Provider`. Parameters are defined as `Equatable` classes for value comparison:

  ```dart
  class ListInterviewsUseCase extends UseCaseWithParams<
      InterviewsSectionEntity, ListInterviewsParams> {
    final IInterviewsRepository _repository;

    Future<Either<Failure, InterviewsSectionEntity>> call(
        ListInterviewsParams params) {
      return _repository.listInterviews(
          page: params.page, limit: params.limit);
    }
  }
  ```

#### Data Layer (External Interfaces)

The data layer implements the contracts defined by the domain layer:

- **API Models** (`data/models/`): Classes with `@JsonSerializable()` for automatic JSON serialization (generated via `build_runner`), plus manual `fromApiResponse()` factory methods for complex nested API responses and `toEntity()` methods for domain conversion. This dual approach handles both flat cache format and nested API format.

- **Data Sources** (`data/datasources/`): Split into interface + implementation:
  - `IFeatureRemoteDataSource`, abstract interface for API operations
  - `remote/`, concrete implementation using `ApiClient` (Dio)
  - `IFeatureLocalDataSource`, abstract interface for cache operations
  - `local/`, concrete implementation using `HiveService`

- **Repository Implementations** (`data/repositories/`): Concrete classes that implement domain interfaces with a **network-first, cache-fallback** strategy:

  ```dart
  class InterviewsRepository implements IInterviewsRepository {
    Future<Either<Failure, InterviewsSectionEntity>> listInterviews(
        ...) async {
      try {
        final remote = await _remoteDataSource.listInterviews(...);
        await _localDataSource.cacheInterviews(remote); // Cache for offline
        return Right(remote.toEntity());
      } on DioException {
        final cached = await _localDataSource.getCachedInterviews();
        if (cached != null) return Right(cached.toEntity());
        return Left(NetworkFailure('No internet and no cached data'));
      }
    }
  }
  ```

#### Presentation Layer (UI + MVVM)

As described in section 7.2, this layer contains Views (widgets), ViewModels (Notifiers), and State classes. It depends on the domain layer (use cases, entities) but never on the data layer directly.

**Why Clean Architecture for Kaarya AI:**

1. **Framework independence:** The domain layer contains zero Flutter imports. If the app were to migrate from Flutter to another framework, the entire business logic survives unchanged.
2. **Testability at every layer:** Use cases can be tested by mocking repository interfaces. Repositories can be tested by mocking data sources. ViewModels can be tested by mocking use cases. Each layer is independently verifiable.
3. **Parallel development:** With clearly defined interfaces (repository contracts, data source contracts), multiple developers can work simultaneously, one on UI, one on API integration, one on caching, without conflicts.
4. **Swap-ability:** The Hive caching layer could be replaced with SQLite, or the Dio HTTP client could be replaced with http package, without any change to the domain or presentation layers. Only the data source implementation changes.
5. **Scalability:** With 15+ features, each following the same Clean Architecture structure, the codebase remains navigable and consistent. New developers can understand any feature by understanding the pattern once.

### 7.5 Repository Pattern

The **Repository Pattern** serves as the bridge between Clean Architecture's domain and data layers. Each feature has a repository interface in the domain layer and a concrete implementation in the data layer. The repository is responsible for:

1. Deciding the data source (remote API vs. local cache)
2. Orchestrating the network-first, cache-fallback strategy
3. Transforming API models to domain entities
4. Handling and categorizing errors into typed `Failure` objects (`ApiFailure`, `NetworkFailure`, `LocalDatabaseFailure`)

This pattern ensures that the domain layer never knows whether data came from a REST API, a local database, or a mock, it simply receives `Either<Failure, Entity>`.

### 7.6 Complete Feature Structure

Every feature in Kaarya AI follows this identical directory structure, ensuring consistency across the entire codebase:

```
lib/features/{feature_name}/
├── domain/
│   ├── entities/          # Pure Dart Equatable classes
│   ├── repositories/      # Abstract interface (IFeatureRepository)
│   └── usecases/          # One class per operation + Provider + Params
├── data/
│   ├── models/            # @JsonSerializable API models + toEntity()
│   ├── datasources/
│   │   ├── i_feature_remote_data_source.dart  # Remote interface
│   │   ├── i_feature_local_data_source.dart   # Local interface
│   │   ├── remote/        # Dio/ApiClient implementation
│   │   └── local/         # Hive implementation
│   └── repositories/      # Concrete repository with caching strategy
└── presentation/
    ├── state/             # FeatureState extends Equatable + copyWith
    ├── view_model/        # FeatureViewModel extends Notifier<State>
    ├── pages/             # Full-screen widgets
    └── widgets/           # Reusable feature-specific components
```

---

## 8. State Management

### 8.1 What is State Management?

State management refers to how an application tracks, stores, and responds to changes in data that affect the user interface. In a mobile application, "state" encompasses everything from whether a user is logged in, to the current list of jobs being displayed, to whether a loading spinner should be visible. Without structured state management, applications become unpredictable, UI may not reflect current data, user actions may have delayed or incorrect effects, and debugging becomes extremely difficult.

State management solutions provide:

- **A single source of truth** for each piece of application state
- **Predictable state transitions**, state only changes through defined operations
- **Reactive UI updates**, widgets automatically rebuild when the state they depend on changes
- **Separation of UI and logic**, business logic lives outside of widgets

### 8.2 Riverpod in Kaarya AI

Kaarya AI uses **flutter_riverpod (v3.0.3)**, the most robust state management solution in the Flutter ecosystem. Riverpod was chosen over alternatives (Provider, Bloc, GetX, MobX) for specific architectural reasons.

**How Riverpod works:**

The entire application is wrapped in a `ProviderScope` at the root (`main.dart`), which acts as the container for all application state:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Provider types used in Kaarya AI:**

1. **`NotifierProvider<VM, State>`**, The primary pattern. Each feature's ViewModel is a `Notifier` that manages an immutable state object. When the ViewModel updates `state`, all widgets watching that provider automatically rebuild:

   ```dart
   final interviewsViewModelProvider =
     NotifierProvider<InterviewsViewModel, InterviewsState>(
       InterviewsViewModel.new,
     );
   ```

2. **`Provider<T>`**, For read-only, computed values and dependency injection. Use cases, repositories, data sources, and services are all provided through `Provider`:

   ```dart
   final listInterviewsUseCaseProvider =
       Provider<ListInterviewsUseCase>((ref) {
     return ListInterviewsUseCase(
         ref.read(interviewsRepositoryProvider));
   });
   ```

3. **`StateProvider<T>`**, For simple, mutable state that doesn't need a full ViewModel. Used for UI-level state like bottom navigation index, filter selections, and toggle states:

   ```dart
   final bottomNavProvider =
       StateProvider<AppDestination>((ref) => AppDestination.overview);
   ```

**Reactive data flow:**

```
User taps "Start Interview"
        │
        ▼
View calls: ref.read(interviewsViewModelProvider.notifier).startSession(id)
        │
        ▼
ViewModel: state = state.copyWith(isLoading: true)
   → All watching widgets rebuild showing loading spinner
        │
        ▼
ViewModel calls: ref.read(startInterviewSessionUseCaseProvider).call(params)
        │
        ▼
UseCase calls: repository.startSession(interviewId)
        │
        ▼
Repository: tries remote API → caches result → returns Either<Failure, Entity>
        │
        ▼
ViewModel: result.fold(
   (failure) => state = state.copyWith(isLoading: false, error: failure.message),
   (session) => state = state.copyWith(isLoading: false, activeSession: session),
)
   → All watching widgets rebuild with new data or error message
```

**Why Riverpod over alternatives:**

| Criteria                | Riverpod                      | Provider             | Bloc                 | GetX       |
| ----------------------- | ----------------------------- | -------------------- | -------------------- | ---------- |
| Compile-time safety     | Yes                           | No (runtime errors)  | Partial              | No         |
| No BuildContext needed  | Yes                           | No                   | No                   | Partial    |
| Testability             | Excellent (ProviderContainer) | Good                 | Good                 | Poor       |
| Auto-dispose            | Built-in                      | Manual               | Manual               | Manual     |
| Dependency injection    | Native (ref.read/watch)       | Requires separate DI | Requires separate DI | Has own DI |
| Code generation support | Optional                      | No                   | Yes (bloc)           | No         |

Riverpod was selected specifically because it enables the Clean Architecture dependency injection pattern, each layer's providers can `ref.read` providers from inner layers, creating a compile-time-safe dependency graph without any service locator or dependency injection framework.

### 8.3 Error Handling with Either (dartz)

State management in Kaarya AI is reinforced by the `Either<Failure, T>` pattern from the `dartz` package. Every repository method returns either a `Failure` (left) or a success value (right). This eliminates try-catch proliferation in ViewModels and makes error states explicit:

```dart
// Three typed failures for different error scenarios:
class ApiFailure extends Failure {
  final int? statusCode;
  final String message;
}

class NetworkFailure extends Failure {
  final String message;  // No internet connection
}

class LocalDatabaseFailure extends Failure {
  final String message;  // Hive read/write error
}
```

This means every ViewModel method handles errors uniformly, and the UI can distinguish between "server error," "no internet," and "cache corrupted" to show appropriate messages.

---

## 9. Sensors and Third-Party APIs

### 9.1 Device Sensors

Kaarya AI integrates four hardware sensors through a centralized `DeviceSensorService` that provides reactive streams for each sensor. All sensors are managed by the `AppSensorEffectsHost` widget, which wraps the entire application and handles lifecycle events (pausing sensors when the app goes to the background, resuming when foregrounded).

#### 9.1.1 Accelerometer, Shake Detection

**Package:** `sensors_plus ^7.0.0`

**Purpose:** Provides a physical gesture shortcut, shaking the device navigates directly to the AI Interview Hub.

**Technical implementation:** The `ShakeDetector` class processes `UserAccelerometerEvent` data from the device's accelerometer. It uses a sophisticated algorithm that requires:

- Acceleration magnitude exceeding **2.2 m/s** threshold
- **3 directional changes** (back-and-forth motion, not just a single jolt)
- All 3 hits occurring within an **850ms time window**
- Minimum **90ms spacing** between hits (filtering sensor noise)
- **3-second cooldown** after each successful detection (preventing repeated triggers)

The algorithm calculates the dominant signed axis strength from the three-axis (x, y, z) accelerometer data and tracks directional changes, ensuring that only intentional shake gestures are recognized, not walking, typing, or accidental bumps.

**User value:** Candidates preparing for interviews can instantly access the AI Interview Hub with a natural shake gesture from the dashboard, reducing navigation friction for the app's most important feature.

#### 9.1.2 Ambient Light Sensor, Adaptive Theme

**Package:** `light_sensor ^3.0.2`

**Purpose:** Automatically adjusts the app's theme (light/dark mode) based on ambient lighting conditions.

**Technical implementation:** The `lightLevelStream()` method provides a continuous stream of lux values from the device's light sensor. The `ThemeModeController` processes these values through the `applyAmbientLux()` method, which adjusts the theme based on configurable lux thresholds. On Android devices with light sensors, this runs continuously while the app is in the foreground, pausing when the app goes to the background to conserve battery.

**User value:** Users moving between bright outdoor environments and dim indoor spaces get automatic theme adjustment without manual toggling, reducing eye strain and improving readability.

#### 9.1.3 Proximity Sensor, Security Logout

**Package:** `proximity_sensor ^1.3.10`

**Purpose:** Enhances security by detecting when the device is covered or held face-down for an extended period, and prompting the user to log out.

**Technical implementation:** The `proximityStateStream()` emits boolean values indicating whether an object is near the sensor. The `AppSensorEffectsHost` implements a sustained threshold monitoring pattern: when proximity is detected continuously for **5 seconds**, a logout confirmation dialog is shown. The system includes:

- A **30-second cooldown** after each dialog display to avoid repeated prompts
- A **600ms "far" debounce**, brief moments where the sensor reads "far" during a sustained "near" period don't reset the timer
- Lifecycle-aware cancellation, the timer is cancelled when the app goes to the background
- Login-gate, only triggers for authenticated users

**User value:** If a user leaves their phone face-down or in a pocket while logged in, the app proactively asks if they want to log out, providing an additional layer of security against unauthorized access.

#### 9.1.4 GPS / Location Picker

**Package:** `location_picker_flutter_map ^4.1.0`

**Purpose:** Enables recruiters to tag job listings with precise geographical locations using an interactive map.

**Technical implementation:** The location picker uses OpenStreetMap tile data via `flutter_map` to render an interactive map where recruiters can search for and select a location when creating a job posting. The selected coordinates are stored with the job listing, enabling future location-based job search features.

**User value:** Candidates can see exactly where a job is located, and recruiters can accurately represent their office location, essential information for local job markets.

### 9.2 Third-Party APIs

#### 9.2.1 VAPI, Voice AI Platform (Custom Integration)

**Type:** Real-time conversational voice AI API

VAPI is a voice AI platform that enables real-time, two-way voice conversations with AI assistants. In Kaarya AI, it powers the mock interview system, the core differentiating feature of the application.

**Integration architecture:**

The VAPI integration consists of three layers:

1. **Custom Local Package** (`packages/vapi/`): A Flutter package maintained within the project that wraps the VAPI SDK. It uses `daily_flutter` (mobile WebRTC library) for real-time audio streaming on Android/iOS and a JavaScript SDK for web.

2. **Service Layer** (`VapiInterviewService`): A Riverpod-provided service that manages VAPI call lifecycle and emits structured events:
   - `callStart`, Interview session has begun, speakerphone activated
   - `callEnd`, Interview session ended
   - `transcript`, Final transcribed speech with role (user/assistant) and timestamp
   - `partialTranscript`, Live in-progress transcription for real-time display
   - `speechStart` / `speechEnd`, Voice activity detection events
   - `error`, Connection or processing errors

3. **Backend Configuration** (`/interviews/vapi/creation-config`): The interview configuration (assistant personality, questions, evaluation criteria) is managed server-side and fetched before each session. This allows the interview content to be updated without app updates.

**Technology stack behind VAPI:**

- **Speech-to-Text:** Real-time transcription engine
- **LLM Processing:** OpenAI GPT for understanding context and generating responses
- **Text-to-Speech:** ElevenLabs for natural, human-like voice synthesis
- **WebRTC:** `daily_flutter` for low-latency, bidirectional audio streaming

**Permissions required:** `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS` (Android); `NSMicrophoneUsageDescription` (iOS)

#### 9.2.2 Stream Chat, Real-Time Messaging API

**Package:** `stream_chat_flutter ^9.23.0`

**Type:** Real-time messaging and communication API

Stream Chat provides enterprise-grade real-time messaging infrastructure. In Kaarya AI, it powers the inbox/messaging feature that enables direct communication between candidates, recruiters, and college administrators.

**Integration:**

- **Chat tokens** are generated server-side (`/stream/chat-token`) and provided to the client for authenticated access
- **Video tokens** (`/stream/video-token`) are also available for future video communication features
- **Channel management** (`/stream/ensure-channels`, `/stream/ensure-channel-with`) is handled server-side, ensuring proper access control
- **Stream config** (`/stream/config`) provides client-side initialization parameters

**Capabilities:** Real-time message delivery, read receipts, typing indicators, media attachments, channel-based conversations, push notifications.

#### 9.2.3 Stripe, Payment Processing API

**Type:** Financial transaction and subscription management API

Stripe handles all payment processing for Kaarya AI's subscription system. The integration follows Stripe's recommended server-side pattern for mobile apps:

1. **Checkout Session Creation** (`/payments/stripe/checkout-session`): The backend creates a Stripe Checkout Session with the plan details, pricing in NPR, and success/cancel redirect URLs.
2. **In-App WebView:** The app opens the Stripe-hosted checkout page in a `WebView`, ensuring PCI DSS compliance, the app never handles raw card numbers.
3. **Session Verification** (`/payments/stripe/verify-session`): After payment, the app verifies the session with the backend, which confirms with Stripe and activates the user's plan.
4. **Customer Portal** (`/payments/stripe/portal-session`): Subscribers can manage their subscription through Stripe's pre-built customer portal.

**Security advantage:** By using Stripe's hosted checkout, the application never touches, stores, or transmits payment card information, all sensitive financial data is handled by Stripe's PCI Level 1 certified infrastructure.

---

## 10. Data and Security

### 10.1 What Data the App Stores

Kaarya AI stores data in two tiers, **local (on-device)** and **remote (cloud server)**, following a network-first, cache-fallback strategy.

#### Local Data (On-Device)

| Storage Mechanism          | Data Stored                                                                                                                                             | Purpose                                     |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| **Flutter Secure Storage** | JWT authentication token, biometric credentials (encrypted email/password)                                                                              | Authentication persistence between sessions |
| **SharedPreferences**      | User session metadata (userId, email, name, role, provider, photo URL), theme preferences, onboarding status                                            | Quick-access UI state and session info      |
| **Hive Database**          | Cached API responses for all features, jobs, interviews, applications, bookmarks, leaderboard, dashboard, companies, colleges, resources, resume drafts | Offline access and reduced API calls        |

**Hive caching detail:** Kaarya AI registers 17 typed Hive adapters across 12 named boxes:

| Hive Box                   | Content                         | TypeIds    |
| -------------------------- | ------------------------------- | ---------- |
| `user_table`               | Authentication and profile data | 0          |
| `jobs_section_table`       | Job listings and sections       | 10, 11     |
| `interviews_section_table` | Interview listings              | 12, 13     |
| `applications_table`       | Application records             | 14         |
| `resumes_table`            | Uploaded resumes                | 15         |
| `bookmarks_table`          | Saved jobs and interviews       | 16, 17, 18 |
| `leaderboard_table`        | Ranking data                    | 19, 20     |
| `overview_table`           | Dashboard overview              | 21         |
| `companies_table`          | Company profiles                | 22         |
| `colleges_table`           | College profiles                | 23         |
| `resources_table`          | Course content                  | 24         |
| `resume_builder_table`     | Resume drafts                   | 25         |

#### Remote Data (Cloud Server)

All persistent, authoritative data is stored on the backend server, accessed via a RESTful API (50+ endpoints). This includes:

- User accounts and authentication credentials (hashed)
- Job listings and application records
- Interview configurations, session recordings, and AI-generated feedback
- Resume drafts and generated PDFs
- Course content and progress records
- Company and college organizational data
- Billing and payment transaction records
- Chat messages (via Stream Chat infrastructure)
- Leaderboard scores and analytics

### 10.2 How Data is Secured

#### Local Security Measures

1. **Encrypted Token Storage:** The JWT authentication token, the most sensitive local data, is stored in `flutter_secure_storage`, which uses:
   - **Android:** AES-256 encryption backed by the Android Keystore system. Keys are stored in hardware-backed secure enclave on supported devices.
   - **iOS:** iOS Keychain Services with `kSecAttrAccessibleWhenUnlocked` access control.

   The app includes a **legacy migration** mechanism that detects tokens previously stored in plain SharedPreferences and automatically migrates them to secure storage, then deletes the plaintext version.

2. **Biometric Credential Protection:** When users enable biometric login, their email and password are encrypted and stored in `flutter_secure_storage`. Biometric authentication (fingerprint or face) must succeed before credentials are decrypted and used for automatic login. The implementation uses `sensitiveTransaction: true` and `stickyAuth: true` flags for maximum security.

3. **Proximity-Based Session Protection:** As described in section 9.1.3, the proximity sensor triggers a logout prompt after sustained coverage, providing physical security for unattended devices.

4. **Session Data Separation:** Sensitive authentication data (tokens, credentials) is stored in encrypted secure storage, while non-sensitive UI data (user name, theme preference) is stored in SharedPreferences. This separation ensures that even if SharedPreferences data were accessed, no authentication credentials would be exposed.

5. **Cache Data Nature:** Hive-cached data is a mirror of already-fetched API data. It does not contain credentials, tokens, or payment information. If the device is compromised, cached data only exposes what the user already had access to view.

#### Remote Security Measures

1. **JWT Token Authentication:** All API requests include a `Bearer` token in the Authorization header. The `_AuthInterceptor` in the `ApiClient` automatically injects the token into every request (except login/signup endpoints):

   ```dart
   handler.next(options..headers['Authorization'] = 'Bearer $token');
   ```

2. **Automatic 401 Handling:** If any API response returns HTTP 401 (Unauthorized), the interceptor automatically:
   - Clears the stored token from secure storage
   - Clears the user session
   - Prevents cascading unauthorized requests

3. **PCI DSS Compliance (Payments):** Payment processing uses Stripe's hosted checkout, meaning the app never handles, stores, or transmits credit card numbers. All financial transactions occur on Stripe's PCI Level 1 certified servers.

4. **OAuth Security:** Google and GitHub OAuth flows use the standard authorization code exchange pattern. OAuth tokens are exchanged server-side (`/auth/oauth/exchange`), and the mobile app only receives the application's JWT, never the OAuth provider's access token.

5. **Error Information Control:** API failures are caught and transformed into typed `Failure` objects that contain user-friendly messages. Raw server errors, stack traces, and implementation details are never exposed to the UI layer. The `PrettyDioLogger` only logs request/response details in debug mode and is stripped from production builds.

### 10.3 Ethical Considerations

1. **Data Minimization:** The app only caches data that the user has explicitly accessed. No background data collection, no tracking of browsing patterns, no device fingerprinting.

2. **User Control:** Users can log out at any time, which clears the authentication token and session data. Biometric login is opt-in, not mandatory.

3. **Transparency:** The billing system shows complete invoice history with transaction UUIDs, amounts, and timestamps, users have full visibility into their financial interactions with the platform.

4. **Interview Data Privacy:** AI interview transcripts and feedback are associated with the user's account and accessible only to them. Interview sessions are personal practice tools, not shared with recruiters unless the candidate explicitly chooses to share.

5. **Institutional Boundaries:** Company and college workspaces have clear permission boundaries, a college administrator can see which students are in their cohort, but cannot access students' private interview transcripts, resume drafts, or application details.

---

---
