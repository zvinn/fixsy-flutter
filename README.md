# 📱 Fixsy Mobile | Flutter Cross-Platform Super-App

<div align="center">

**Enterprise-Grade On-Demand Home Services & Maintenance Mobile Application for iOS & Android**

[![Flutter](https://img.shields.io/badge/Flutter_3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart_3-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase_Suite-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Riverpod](https://img.shields.io/badge/State_Riverpod-00599C?style=for-the-badge)](https://riverpod.dev/)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-brightgreen?style=for-the-badge)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![NestJS](https://img.shields.io/badge/Backend-NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)](https://nestjs.com/)

</div>

---

## 📖 Overview

**Fixsy Mobile** is a production-ready, cross-platform mobile application built using **Flutter & Dart**, architected with strict **Clean Architecture** principles and **Riverpod** state management. It connects customers in Egypt and MENA with vetted, professional technicians across 10+ home maintenance trades.

---

## 🏛️ System Architecture

`
lib/
├── core/             # Theme, Constants, Security, Localization, Common Utils
├── domain/           # Pure Business Logic: Entities, UseCases & Repository Contracts
├── data/             # Data Sources, Models, Firebase Services & Repository Impls
├── presentation/     # UI Layer: Riverpod Providers, Screens & Modular Widgets
└── routes/           # Declarative App Navigation & Deep Linking
`

---

## ✨ Key Mobile Features

- 🤖 **AI Smart Diagnosis:** Integrated computer vision and text analysis for instant fault diagnosis and transparent price range estimation.
- 🗺️ **Live Map & Technician Tracking:** Google Maps & Leaflet integration displaying nearby verified craftsmen in real-time.
- 💬 **In-App Direct Chat:** Low-latency bidirectional messaging between customer and technician backed by Cloud Firestore.
- 💳 **Digital Wallet & Payments:** In-app balance, referral cashback, transaction ledger, and payment gateway integration.
- 🎯 **Gamification Engine:** Dynamic achievement badges, daily task streaks, and performance ratings for technicians.
- 👥 **Multi-Role Portals:**
  - **Client App:** On-demand booking, scheduled appointments, service history, and coupon redemption.
  - **Technician App:** Instant job notifications, status updates (Heading, In Progress, Completed), and daily payout ledger.
  - **Admin Control:** System-wide monitoring and audit controls.
- 🛡️ **Offline & Resiliency:** Local caching via shared_preferences and network connectivity monitors.

---

## 🛠️ Tech Stack

| Layer | Technologies |
|---|---|
| **Framework** | Flutter 3.24+ / 3.38+ (Android, iOS, Web, macOS, Windows) |
| **Language** | Dart 3.0+ |
| **State Management** | Flutter Riverpod & Provider |
| **Backend & Database** | Firebase Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging (FCM) |
| **Microservices Backend** | NestJS & TypeScript (ackend/) |
| **Maps & Location** | Google Maps Flutter, Flutter Map, Geolocator |
| **Animations** | Flutter Animate, Lottie, Shimmer loading |
| **Networking & HTTP** | Dio & Http |
| **Quality & Tests** | Mockito, Fake Cloud Firestore, Firebase Auth Mocks |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10.4 or higher)
- Dart SDK (v3.0 or higher)
- Android Studio / Xcode

### Setup & Run
1. Clone the repository:
   `ash
   git clone https://github.com/zvinn/fixsy-flutter.git
   cd fixsy-flutter
   `
2. Install Flutter dependencies:
   `ash
   flutter pub get
   `
3. Run on connected device or simulator:
   `ash
   flutter run
   `

---

## 👨‍💻 Author

**Mohamed Saad (zvinn)**  
Full Stack & Mobile Engineer (Web • Flutter • Cloud)  
GitHub: [@zvinn](https://github.com/zvinn)  
Email: [mhamed.saad.ibrahim@gmail.com](mailto:mhamed.saad.ibrahim@gmail.com)
