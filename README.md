<div align="center">

# 🌍 TravelSphere

### *Explore the World, Your Way*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Release](https://img.shields.io/github/v/release/akshayev/TravelSphere?style=for-the-badge&color=blueviolet)](https://github.com/akshayev/TravelSphere/releases)

> **A premium full-stack travel booking mobile application** built with Flutter & Firebase — featuring real-time bookings, AI-assisted trip planning, admin dashboard, interactive maps, and a stunning glassmorphic dark UI.

[📱 Download APK](#-download--install) • [✨ Features](#-features) • [🛠️ Tech Stack](#️-tech-stack) • [🔐 Security](#-security) • [🚀 Setup](#-setup-guide)

---

</div>

## 📸 App Screenshot

<div align="center">

| Login Screen | Home — Explore | Package Details |
|:-:|:-:|:-:|
| ![Login](screenshots/01_login.png) | ![Home](screenshots/02_home_explore.png) | ![Package Details](screenshots/03_package_details.png) |
| *Email/Password + Google Sign-In* | *Discover destinations with category filters & real-time pricing* | *Full trip info — duration, location, rating, map & booking* |

| My Trips | Admin Dashboard |
|:-:|:-:|
| ![My Trips](screenshots/04_my_trips.png) | ![Admin Dashboard](screenshots/05_admin_dashboard.png) |
| *Upcoming/Past/Saved tabs with live booking status & cancel flow* | *System overview — packages, users, bookings, revenue KPIs* |

</div>

---

## ✨ Features

### 👤 User Experience
| Feature | Description |
|---|---|
| 🔐 **Multi-Auth** | Google OAuth + Email/Password login with password reset |
| 🏠 **Smart Home Feed** | Category-filtered, real-time destination cards from Firestore |
| 🔍 **Package Discovery** | Browse 30+ curated India travel packages with rich media |
| 📦 **Package Details** | Tabbed view (Overview / Itinerary / Inclusions) with image carousel |
| 📅 **Booking System** | Date picker, traveler count, real-time price calculation + confirm |
| 🧳 **My Trips** | Full booking history with status tracking (Confirmed / Cancelled) |
| ❤️ **Saved Packages** | Atomic Firestore transactions for wishlist save/unsave |
| 🗺️ **Interactive Maps** | OpenStreetMap (FlutterMap) with location pinning |
| 🤖 **AI Trip Planner** | Intelligent itinerary generator based on destination, budget & style |
| 💰 **Budget Planner** | Dynamic cost breakdown and trip expense calculator |
| 🔔 **Push Notifications** | Local notification system for booking confirmations |
| 👤 **Rich Profile** | Avatar upload (base64), bio, phone, birth year, notification prefs |

### 🛡️ Admin Powers
| Feature | Description |
|---|---|
| 📊 **Admin Dashboard** | Stats overview: packages, bookings, revenue KPIs |
| ➕ **Create Package** | Full form with image upload, itinerary builder, inclusions list, map picker |
| ✏️ **Edit Package** | Inline edit with pre-filled form and live Firestore update |
| 🗑️ **Delete Package** | Confirmation dialog + Firestore deletion |
| 📋 **Booking Management** | View all user bookings, update statuses |
| 🗺️ **Map Picker** | Admin can pin exact destination coordinates via OpenStreetMap |

---

## 🛠️ Tech Stack

```
┌─────────────────────────────────────────────────────────────┐
│                     TravelSphere Stack                      │
├──────────────────────┬──────────────────────────────────────┤
│  Frontend Framework  │  Flutter 3.x (Dart 3.x)             │
│  State Management    │  StatefulWidget + Streams (reactive) │
│  UI / Design         │  Material 3 · Glassmorphism · Dark   │
│  Navigation          │  Named Routes (onGenerateRoute)      │
│  Typography          │  Google Fonts (Playfair / Poppins)   │
├──────────────────────┼──────────────────────────────────────┤
│  Authentication      │  Firebase Auth (Email + Google)      │
│  Database            │  Cloud Firestore (NoSQL, real-time)  │
│  Storage             │  Base64 in Firestore (no ext. dep)   │
│  Push Notifications  │  flutter_local_notifications         │
├──────────────────────┼──────────────────────────────────────┤
│  Maps                │  FlutterMap + OpenStreetMap (free)   │
│  Image Handling      │  image_picker + SmartNetworkImage    │
│  HTTP Images         │  cached_network_image                │
│  Date/Time           │  intl + DatePicker                   │
│  URL Launch          │  url_launcher                        │
└──────────────────────┴──────────────────────────────────────┘
```

### Architecture Pattern
```
lib/
├── app/              # Routes, Theme, App config
├── models/           # Data models (TravelPackage, User, Booking)
├── services/         # Business logic & Firebase layer
│   ├── auth_service.dart
│   ├── booking_service.dart
│   ├── travel_package_service.dart
│   ├── user_service.dart
│   ├── itinerary_generator.dart
│   └── notification_service.dart
├── screens/
│   ├── auth/         # Login, Signup, Forgot Password
│   ├── splash/       # Animated splash with auth check
│   ├── dashboard/    # Main app shell with bottom nav
│   ├── user/         # Home, Packages, Planner, Bookings, Profile
│   └── admin/        # Admin dashboard + package management
├── widgets/          # Reusable UI components
└── utils/            # Helpers, constants, extensions
```

---

## 📱 Download & Install

### 🤖 Android APK (Latest Release)

> **⬇️ [Download TravelSphere v1.0.0 APK](https://github.com/akshayev/TravelSphere/releases/latest)**

**Installation Steps:**
1. Download `TravelSphere-v1.0.0-release.apk` from Releases
2. On your Android phone, go to **Settings → Security → Unknown Sources** → Enable
3. Open the downloaded APK and tap **Install**
4. Launch TravelSphere and sign in with your Google account

**Requirements:** Android 6.0 (API 23) and above

---

## 🚀 Setup Guide

### Prerequisites
```bash
# Required tools
Flutter SDK >= 3.0.0   (flutter.dev/install)
Dart SDK >= 3.0.0      (bundled with Flutter)
Android Studio         (for Android emulator/build)
Firebase CLI           (npm install -g firebase-tools)
```

### 1. Clone the Repository
```bash
git clone https://github.com/akshayev/TravelSphere.git
cd TravelSphere
```

### 2. Firebase Configuration
This project requires Firebase. Set up your own Firebase project:

```bash
# Login to Firebase
firebase login

# Initialize Firebase in the project
flutterfire configure
```

This generates `lib/firebase_options.dart` and `android/app/google-services.json` automatically.

> ⚠️ **Important:** `google-services.json` and `firebase_options.dart` are gitignored for security. You must configure your own Firebase project.

### 3. Firestore Security Rules
Deploy the included security rules:
```bash
firebase deploy --only firestore:rules
```

### 4. Install Dependencies & Run
```bash
flutter pub get
flutter run
```

### 5. Set Up Admin Account
After signing up, manually set your role to `admin` in Firestore:
```
Firestore → users → [your-uid] → role: "admin"
```

---

## 🔐 Security

### Firestore Security Rules Summary
```
✅ Users can only read/write their own profile document
✅ Only admins can create, update, or delete travel packages
✅ Users can only see and manage their own bookings
✅ Package & category reads are public (no auth required for browsing)
✅ Booking creation enforces userId == request.auth.uid (no impersonation)
✅ Admin role is verified server-side via Firestore get() — not client trust
```

### Security Measures Implemented
- 🔒 Firebase Auth handles all credential management (no passwords stored locally)
- 🔑 Admin role elevation verified server-side in Firestore rules (never client-side)
- 🚫 Sensitive files (`google-services.json`, `firebase_options.dart`) are `.gitignored`
- 📦 No hardcoded API keys or secrets in source code
- 🖼️ Images stored as base64 in Firestore to avoid unauthenticated Storage bucket access
- ✅ Booking creation enforces server-side ownership validation
- 🛡️ `kDebugMode` guards all sensitive logging (no logs in production)
- 🔐 Google OAuth via official `google_sign_in` package (no manual token handling)

### Known Limitations (Documented)
| Issue | Risk Level | Notes |
|---|---|---|
| Base64 images in Firestore | Low | Firestore document size limit (1MB) acts as natural throttle |
| No email verification enforcement | Low | Users can sign in without verifying email |
| Admin role via Firestore document | Medium | Secure server-side; mitigated by rules + manual assignment |
| No rate limiting | Low | Firebase has built-in quota protection |

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary Color | `#5C6BC0` (Indigo 400) |
| Accent / Gold | `#FFD700` |
| Background (Dark) | `#0D1117` |
| Surface (Dark) | `#161B22` |
| Card Glassmorphism | `rgba(255,255,255,0.08)` + `blur(10px)` |
| Font (Display) | Playfair Display |
| Font (Body) | Poppins / Inter |
| Border Radius | 16px (cards), 24px (modals) |
| Theme | Dark + Light (system adaptive) |

---

## 👨‍💻 Developer

<div align="center">

**Akshay** — Flutter Developer

[![GitHub](https://img.shields.io/badge/GitHub-akshayev-181717?style=flat-square&logo=github)](https://github.com/akshayev)

*Built with ❤️ using Flutter & Firebase*

</div>

---

## 📄 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

---

<div align="center">

**⭐ If you found this project impressive, please give it a star!**

*TravelSphere — Where Every Journey Begins*

</div>
