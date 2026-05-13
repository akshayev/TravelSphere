# TravelSphere 🌍 - Agent Project Memory

**Purpose**: This memory file serves as the definitive reference for the autonomous agent working on the TravelSphere project. It contains a deep analysis of the application's architecture, dependencies, design patterns, and operational rules.
**Action Requirement**: This file MUST be updated with every significant architectural change, new feature, or refactor to maintain an accurate internal context.

## 1. Project Overview
TravelSphere is a modern, production-level, full-stack travel planning application built with Flutter & Firebase. It allows users to discover curated travel packages, generate itineraries, and book premium experiences. It follows a "vibrant glassmorphism" aesthetic.

## 2. Tech Stack & Infrastructure
- **Frontend**: Flutter & Dart (SDK >=3.10.7 <4.0.0)
- **Backend/DB**: Firebase Authentication, Cloud Firestore (NoSQL), Firebase Cloud Storage
- **Mapping**: `flutter_map` & `latlong2` (OpenStreetMap integration)
- **UI/UX**: `google_fonts`, custom `GlassContainer` widgets
- **Auth Methods**: Email/Password, Google Sign-In (`google_sign_in`)

## 3. Core Architecture & Modularity
The codebase follows a strict feature-based directory structure under `lib/`:
- `lib/app/`: Application-wide configuration, routing (`routes.dart`), and thematic constants (`theme.dart`).
- `lib/models/`: Strictly typed data models for Firestore serialization (`package_model.dart`, `trip_model.dart`, etc.).
- `lib/screens/`: Feature-based UI components categorized logically (`admin`, `auth`, `user`, `splash`).
- `lib/services/`: Core business logic that strictly isolates Firebase transactions from UI code (`auth_service.dart`, `travel_package_service.dart`, etc.).
- `lib/widgets/`: Reusable UI widgets, specifically the signature `GlassContainer` for the frosted-glass design system.

## 4. Key Components & "God Nodes"
Based on graph dependency analysis, the following files are highly central and require caution when editing:
- **`lib/app/routes.dart`**: The central routing hub. Changes here affect global navigation.
- **`lib/main.dart`**: Entry point (Firebase initialization, Theme setup).
- **`lib/app/theme.dart`**: Source of truth for the glassmorphic and vibrant design system.
- **`lib/models/package_model.dart`**: The core data structure tying Admin creations to User consumption.
- **`lib/services/auth_service.dart`**: The primary hub for user state, authentication, and Role-Based Access Control (RBAC).

## 5. Major Domains / Clusters
1.  **Admin Domain (`lib/screens/admin`)**: Dashboard and forms (`package_form_dialog.dart`, `admin_map_picker_screen.dart`) for creating travel packages directly into Firestore. Only accessible by users with the 'admin' role.
2.  **User Navigation Domain (`lib/screens/user`)**: End-user features including `home`, `itinerary`, `profile`, `planner`, `budget_planner`, and `package_details`.
3.  **Auth & Onboarding Domain (`lib/screens/auth` & `splash`)**: Login, Signup, and Password recovery screens.

## 6. Developer & Agent Guidelines
- **Production Quality**: Do not leave `print()` statements in production code. Ensure all Firebase calls have proper error handling (`try-catch` blocks) and loading states are reflected in the UI.
- **Design System Enforcement**: Any new UI components must leverage `AppTheme` colors and `GlassContainer` widgets to match the premium, glassmorphic look. Do not hardcode generic colors.
- **Role-Based Security**: Always verify a user's role before exposing Admin functionality.
- **Data Serialization**: When modifying Firestore structure, always update the respective `.fromJson` and `.toJson` methods in `lib/models/`.

## 7. Change Log (Agent Operations)
*(Update this section on each task completion to retain context)*
- **[2026-05-13]**: Generated initial deep analysis and memory file for TravelSphere agent tracking.
- **[2026-05-13]**: Systematically migrated all deprecated `.withOpacity()` API usages to modern `.withValues(alpha: ...)` across the entire application, while enforcing `dart analyze` to ensure a completely clean, zero-warning codebase.
