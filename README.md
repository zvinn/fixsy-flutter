# 📱 Fixsy Mobile | Flutter Cross-Platform Super-App

<div align="center">

**Enterprise-Grade On-Demand Home Services & Maintenance Mobile Application for iOS & Android**

[![Fixsy Flutter CI](https://github.com/zvinn/fixsy-flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/zvinn/fixsy-flutter/actions/workflows/flutter.yml)
[![Tests: 125 Passed](https://img.shields.io/badge/Tests-125%20Passed-brightgreen.svg?style=flat-square)](test/)
[![Flutter](https://img.shields.io/badge/Flutter_3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart_3-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase_Suite-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Provider](https://img.shields.io/badge/State-Provider-blue?style=flat-square)](https://pub.dev/packages/provider)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-brightgreen?style=flat-square)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

</div>

---

## 📖 Overview

**Fixsy Mobile** is a production-ready, cross-platform mobile application built using **Flutter & Dart**, architected with strict **Clean Architecture** principles and **Provider** state management. It connects customers with vetted, professional technicians across 10+ home maintenance trades (Plumbing, Electrical, Carpentry, Painting, AC repair, and more).

---

## 🏛️ System Architecture

```text
lib/
├── core/             # Theme, Constants, Security, Localization, Common Utils
├── domain/           # Pure Business Logic: Entities, UseCases & Repository Contracts
├── data/             # Data Sources, Models, Firebase Services & Repository Impls
├── presentation/     # UI Layer: State Providers, Screens & Modular Widgets
└── routes/           # Declarative App Navigation & Deep Linking
```

---

## ✨ Key Mobile Features

- 🔐 **Comprehensive Authentication:**
  - Email/Password login & signup with form validations and rate limiting.
  - Social Logins: **Google Sign-In** & **Apple Sign-In**.
  - **Quick Demo Accounts:** 1-click login for Client, Technician, and Admin roles.
  - Password Reset with in-app email reset link generator.
- 🤖 **AI Smart Diagnosis:** Integrated computer vision and text analysis for instant fault diagnosis and transparent price range estimation.
- 🗺️ **Live Map & Technician Tracking:** Google Maps & Leaflet integration displaying nearby verified craftsmen in real-time.
- 💬 **In-App Direct Chat:** Low-latency bidirectional messaging between customer and technician with Voice Recording backed by Cloud Firestore.
- 📅 **Multi-Step Booking Flow:** Service picker, issue description, schedule picker, coupon validation, and multi-payment selector (Cash, Card, Wallet).
- 💳 **Digital Wallet & Payments:** In-app balance, referral cashback, transaction ledger, and payment gateway integration.
- 🎯 **Gamification Engine:** Dynamic achievement badges, daily task streaks, and performance ratings for technicians.
- 👥 **Multi-Role Portals:**
  - **Client App:** On-demand booking, scheduled appointments, service history, and coupon redemption.
  - **Technician App:** Instant job notifications, status updates, and task management.
  - **Admin Control:** System-wide monitoring and audit controls.
- 🛡️ **Offline & Resiliency:** Local caching via `shared_preferences` and network connectivity monitors.

---

## 🛠️ Tech Stack

| Layer | Technologies |
|---|---|
| **Framework** | Flutter 3.x (Android, iOS, Web, Windows) |
| **Language** | Dart 3.0+ |
| **State Management** | Provider |
| **Backend & Database** | Firebase Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging (FCM) |
| **Maps & Location** | Google Maps Flutter, Flutter Map, LatLong2, Geolocator |
| **Animations** | Flutter Animate, Lottie, Shimmer loading |
| **Networking & HTTP** | Dio & Http |
| **Testing & Quality** | 125 Automated Unit & Widget Tests, GitHub Actions CI/CD |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10.4 or higher)
- Dart SDK (v3.0 or higher)
- Android Studio / Xcode / VS Code

### Setup & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/zvinn/fixsy-flutter.git
   cd fixsy-flutter
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run tests:
   ```bash
   flutter test
   ```
4. Run on connected device or simulator:
   ```bash
   flutter run
   ```

---

## 🧪 Test Suite

All 125 unit and widget tests pass:
```bash
flutter test
# 00:09 +125: All tests passed!
```

---

## 👨‍💻 Author

**Mohamed Saad (zvinn)**  
Full Stack & Mobile Engineer (Web • Flutter • Cloud)  
GitHub: [@zvinn](https://github.com/zvinn)  
Email: [mhamed.saad.ibrahim@gmail.com](mailto:mhamed.saad.ibrahim@gmail.com)
