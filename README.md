# 📱 Fixsy Mobile — On-Demand Services Super-App

<div align="center">

<img src="https://raw.githubusercontent.com/zvinn/fixsy-flutter/main/assets/icons/app_icon.png" width="96" height="96" alt="Fixsy Logo" onerror="this.src='https://img.icons8.com/color/96/wrench.png';" />

### **Enterprise-Grade On-Demand Home Services & Maintenance Platform**
*Built with Flutter, Clean Architecture, Provider, and Firebase*

[![Fixsy Flutter CI](https://github.com/zvinn/fixsy-flutter/actions/workflows/flutter.yml/badge.svg)](https://github.com/zvinn/fixsy-flutter/actions/workflows/flutter.yml)
[![Tests: 249 Passed](https://img.shields.io/badge/Tests-249%20Passed%20(100%25)-brightgreen.svg?style=flat-square&logo=flutter)](test/)
[![Analysis: 0 Issues](https://img.shields.io/badge/Flutter%20Analyze-0%20Issues%20(Clean)-brightgreen?style=flat-square&logo=dart)](.)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.x%20Ready-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet?style=flat-square)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](CONTRIBUTING.md)

<br/>

[![Live Demo](https://img.shields.io/badge/🚀_Live_Demo-Try_in_Browser-2ea44f?style=for-the-badge&logo=googlechrome&logoColor=white)](https://zvinn.github.io/fixsy-flutter/)

<br/>

[Features](#-feature-showcase) • [Architecture](#-system-architecture) • [Demo Accounts](#-one-click-demo-accounts) • [Getting Started](#-getting-started) • [Test Suite](#-rigorous-testing--quality)

⭐ **If you find this repository helpful, please give it a Star! It helps the project grow.** ⭐

</div>

---

## 📖 About Fixsy

**Fixsy** is a production-ready, full-featured mobile super-application for on-demand home maintenance and technical services (Plumbing, Electrical, HVAC, Carpentry, Painting, Cleaning, and more). 

Engineered with enterprise-grade standards, Fixsy adheres strictly to **Clean Architecture** patterns, achieving zero analyzer warnings and 100% automated test coverage across **249 comprehensive unit and widget tests**.

### 🌟 Why Fixsy Stands Out?
- 🚀 **100% Production-Grade Clean Code:** 0 issues on `flutter analyze`, clean modularization, and strict separation of concerns.
- 📱 **3-in-1 Unified Multi-Role App:** Seamless role-switching between **Customer**, **Technician**, and **System Administrator**.
- 📶 **Robust Offline-First Engine:** Intelligent local queue that buffers actions during network outages and syncs seamlessly upon reconnection.
- 🤖 **AI-Powered Diagnostics:** Built-in smart diagnosis assisting users in identifying issues and estimating costs before technicians arrive.

---

## 📸 Screen Preview & Highlights

| 🏠 Home & Services | 📅 Slot Scheduling | 📊 Technician Dashboard |
| :---: | :---: | :---: |
| Browse 10+ categories, search with voice, stories, & emergency alerts | Multi-step booking, recurring appointments, & instant dispatch | Live earnings chart, status pipeline, & schedule management |

| 💼 Job Marketplace | 👛 Digital Wallet | 🛡️ Admin Control Panel |
| :---: | :---: | :---: |
| Open job bids, transparent pricing, & distance filters | Ledger history, top-ups, withdrawals, & voucher redemption | Verification queue, coupon factory, dispute resolutions & broadcasts |

---

## ✨ Feature Showcase

### 1. 🔐 Robust Authentication & Profiles
- **Multiple Login Methods:** Email & password, **Google Sign-In**, and **Apple Sign-In**.
- **Quick Demo Mode:** Instant one-click switch between Client, Technician, and Admin roles without entering credentials.
- **Complete Profile & Settings:** Saved addresses management (CRUD + set default), loyalty tiers, referral bonuses, dark/light theme, and language switcher (Arabic/English).

### 2. 📅 Smart Booking & Slot Scheduling
- **Urgent vs. Scheduled:** Toggle between immediate arrival (with live technician dispatch) or scheduled time-slots.
- **Recurrence Engine:** Support for single visits, weekly, bi-weekly, or monthly automated maintenance cycles.
- **Multiple Payment Channels:** Cash on delivery, credit/debit cards, and in-app digital wallet with coupon promo code validation.

### 3. 🛠️ Technician Pro Hub
- **Interactive Dashboard:** 7-day visual earnings chart, active jobs pipeline (Accepted ➔ En Route ➔ In Progress ➔ Completed).
- **Availability & Schedule Manager:** One-tap toggle for on-duty/off-duty mode, slot customization, and working hours planner.
- **Ratings & Reviews:** Detailed customer reviews breakdown, badge credentials, and performance metrics.

### 4. 💼 Open Job Marketplace
- **Direct Job Postings:** Clients post custom maintenance requests with photos, budget expectations, and urgency levels.
- **Technician Bidding:** Verified technicians browse open market jobs, filter by category or distance, and submit competitive bids.

### 5. 👛 Digital Wallet & Financial Engine
- **In-App Wallet:** Full balance management with instant deposit, withdrawal requests, and transaction ledger.
- **Promos & Vouchers:** Built-in voucher redemption system granting instant promotional credits.

### 6. 💬 Real-Time Chat & Voice Messaging
- **Low-Latency Messaging:** Bidirectional chat powered by Cloud Firestore.
- **Voice Messages:** Integrated voice recorder widget allowing audio notes between clients and technicians.
- **Push Notifications:** Foreground and background push alerts via Firebase Cloud Messaging (FCM).

### 7. 🗺️ Live Map & Technician Tracking
- **Real-Time GPS Tracking:** Live map screen displaying nearby technicians, routing, and dynamic ETA calculation.

### 8. 🛡️ Comprehensive Admin Control Center
- **System KPIs & Analytics:** Revenue graphs, active bookings counter, and dispute trackers.
- **Technician Verification:** Document inspection modal with single-tap approval or rejection.
- **Coupon Manager:** Create and manage promotional discount codes with expiration dates.
- **Dispute Resolution & Broadcasts:** Handle customer claims and broadcast emergency notifications.

### 9. 📶 Offline Sync Queue
- Automatically intercepts actions when internet connectivity drops, queues mutations safely, and syncs with the remote backend once connection is restored.

---

## 🏛️ System Architecture

Fixsy follows **Robert C. Martin's Clean Architecture** principles, guaranteeing decoupled business logic from UI frameworks and third-party plugins:

```text
lib/
├── core/                         # Global cross-cutting infrastructure
│   ├── config/                   # Environment variables & constants
│   ├── error/                    # Custom exceptions & centralized error handlers
│   ├── l10n/                     # Internationalization (Arabic & English)
│   ├── security/                 # Input sanitization, data masking & crypto utils
│   ├── theme/                    # Modern design system (Colors, Typography, Spacing)
│   └── utils/                    # AppLogger, responsive helpers, & transitions
│
├── domain/                       # Pure business domain layer (No Flutter dependencies)
│   └── entities/                 # Domain entities & business contracts
│
├── data/                         # Data layer (Implementations & APIs)
│   ├── datasources/              # Remote data sources & local databases
│   ├── models/                   # JSON serializable data models
│   ├── repositories/             # Concrete repository implementations
│   ├── seeders/                  # Mock data & initial Firestore populator
│   └── services/                 # Firebase, Chat, Wallet, Admin, & Rating services
│
├── presentation/                 # Presentation & UI layer
│   ├── layouts/                  # Main layout shells & navigation scaffolds
│   ├── providers/                # State management via Provider (20+ providers)
│   ├── screens/                  # Feature screens (Auth, Booking, Tech, Admin, etc.)
│   └── widgets/                  # Modular, reusable atomic UI components
│
└── routes/                       # Declarative route definitions & transitions
```

---

## 🔑 One-Click Demo Accounts

Fixsy includes pre-configured demo credentials embedded directly on the login screen for rapid evaluation:

| Role | Email | Password | Permissions |
|---|---|---|---|
| 👤 **Client (Customer)** | `client@fixsy.com` | `client123` | Browse, Book, Chat, Wallet, Reviews |
| 🔧 **Technician** | `tech@fixsy.com` | `tech123` | Accept jobs, Manage schedule, Track earnings |
| 🛡️ **Administrator** | `admin@fixsy.com` | `admin123` | Verify techs, Manage coupons, System metrics |

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology |
|---|---|
| **Framework** | [Flutter 3.x](https://flutter.dev/) (Targeting Android & iOS) |
| **Language** | [Dart 3.x](https://dart.dev/) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Backend & Cloud** | [Firebase](https://firebase.google.com/) (Auth, Firestore, Cloud Storage, FCM) |
| **Mapping & Location** | [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter) & [Geolocator](https://pub.dev/packages/geolocator) |
| **Data Visualization** | [FL Chart](https://pub.dev/packages/fl_chart) (Responsive charts for Admin & Tech earnings) |
| **Animations & UI** | [Flutter Animate](https://pub.dev/packages/flutter_animate), [CachedNetworkImage](https://pub.dev/packages/cached_network_image) |
| **Testing** | Flutter Test Framework, Mockito, Automated CI/CD |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.10.4`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.0.0`)
- Android Studio / VS Code with Flutter extension
- Firebase project configured (or run with mock fallback providers)

### Quick Installation

```bash
# 1. Clone the repository
git clone https://github.com/zvinn/fixsy-flutter.git

# 2. Navigate to project root
cd fixsy-flutter

# 3. Fetch dependencies
flutter pub get

# 4. Verify code quality (0 issues expected)
flutter analyze

# 5. Run the test suite (all 249 tests passing)
flutter test

# 6. Launch the application
flutter run
```

---

## 🧪 Rigorous Testing & Quality

Code quality is validated on every commit with **100% passing tests**:

```bash
flutter test
```

```text
00:49 +249: All tests passed!
```

- **Unit Tests:** Business logic, Provider state machines, service layers, and data models.
- **Widget Tests:** Screen rendering, modal bottom sheets, responsive forms, and user interaction simulations.
- **Static Analysis:** Strictly configured `analysis_options.yaml` resulting in **0 warnings and 0 errors**.

---

## 🤝 Contributing

Contributions are warmly welcomed! If you'd like to improve Fixsy:

1. Fork the Project (`https://github.com/zvinn/fixsy-flutter/fork`)
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

## 👨‍💻 Author & Maintainer

**Mohamed Saad (zvinn)**  
*Full Stack & Mobile Engineer (Flutter • React • Cloud Architecture)*

- GitHub: [@zvinn](https://github.com/zvinn)
- Email: [mhamed.saad.ibrahim@gmail.com](mailto:mhamed.saad.ibrahim@gmail.com)
- Project Repository: [fixsy-flutter](https://github.com/zvinn/fixsy-flutter)

---

<div align="center">

**Give Fixsy a ⭐️ if this project helped or inspired your Flutter journey!**

</div>
