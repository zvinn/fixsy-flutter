# 🗺️ Fixsy Flutter — Codebase Map

> **Quick navigation guide** — كل ملف في المشروع بوظيفته ومكانه.
> Last Updated: 2026-09-24

---

## 📁 Project Root

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dependencies & assets config |
| `firebase.json` | Firebase hosting config |
| `.github/workflows/flutter.yml` | CI/CD → GitHub Pages auto-deploy |
| `CODEBASE_MAP.md` | This file |

---

## 🚀 Entry Points — `lib/`

| File | Purpose |
|------|---------|
| `lib/main.dart` | Main entry (Firebase init, providers, theme) |
| `lib/main_shared.dart` | Shared app bootstrap logic |
| `lib/main_client.dart` | Client flavor entry |
| `lib/main_partner.dart` | Partner/Technician flavor entry |

---

## 🎨 Core — `lib/core/`

### Config
| File | Purpose |
|------|---------|
| `lib/core/config/env_config.dart` | Environment variables (API keys, etc.) |
| `lib/core/config/firebase_config.dart` | Firebase options per platform |

### Constants
| File | Purpose |
|------|---------|
| `lib/core/constants/app_constants.dart` | App-wide constants (strings, limits) |

### Error Handling
| File | Purpose |
|------|---------|
| `lib/core/error/exceptions.dart` | Custom exception classes (AuthException, NetworkException, etc.) |
| `lib/core/error/app_error_handler.dart` | Maps Firebase/API errors → user-friendly messages |
| `lib/core/error/error_logger.dart` | Error logging utility |

### Localization (i18n)
| File | Purpose |
|------|---------|
| `lib/core/l10n/app_localizations.dart` | Localization delegate & interface |
| `lib/core/l10n/translations_ar.dart` | Arabic translations |
| `lib/core/l10n/translations_en.dart` | English translations |

### Security
| File | Purpose |
|------|---------|
| `lib/core/security/security_utils.dart` | Rate limiting, email sanitization, masking |

### Theme ⭐
| File | Purpose |
|------|---------|
| `lib/core/theme/app_theme.dart` | Primary brand colors, typography, light/dark themes |

### Utils
| File | Purpose |
|------|---------|
| `lib/core/utils/app_logger.dart` | Structured logging (AppLogger.info/warn/error) |
| `lib/core/utils/validators.dart` | Form validation (email, phone, password rules) |
| `lib/core/utils/date_utils.dart` | Date formatting & helpers |
| `lib/core/utils/responsive_utils.dart` | Breakpoints, screen size helpers |
| `lib/core/utils/ui_helpers.dart` | Common UI helpers (snackbars, dialogs) |
| `lib/core/utils/page_transitions.dart` | Custom route transition animations |

---

## 🗄️ Data — `lib/data/`

### Models (Data Layer DTOs)
| File | Model | Key Fields |
|------|-------|------------|
| `lib/data/models/user.dart` | User | id, email, role (client/technician/admin) |
| `lib/data/models/booking_model.dart` | Booking | clientId, techId, status, serviceType |
| `lib/data/models/service_model.dart` | Service | name, category, price, icon |
| `lib/data/models/service_request.dart` | ServiceRequest | description, images, urgency level |
| `lib/data/models/rating_model.dart` | Rating | stars, comment, techId, clientId |
| `lib/data/models/address_model.dart` | AddressModel | label, lat/lng, isDefault |
| `lib/data/models/conversation_model.dart` | Conversation | participants, lastMessage |
| `lib/data/models/message_model.dart` | Message | text, senderId, timestamp, type |
| `lib/data/models/notification_model.dart` | AppNotification | title, body, type, isRead |
| `lib/data/models/transaction_model.dart` | Transaction | amount, type, walletId |
| `lib/data/models/market_job_model.dart` | MarketJob | title, budget, techId, status |
| `lib/data/models/community_question_model.dart` | CommunityQuestion | question, answers, votes |
| `lib/data/models/admin_model.dart` | AdminStats | platform metrics |

### Services (Firebase/API calls) ⭐
| File | Service | Handles |
|------|---------|---------|
| `lib/data/services/auth_service.dart` | AuthService | Login, Register, Google/Apple Sign-in, Demo accounts |
| `lib/data/services/firestore_service.dart` | FirestoreService | Generic Firestore CRUD operations |
| `lib/data/services/chat_service.dart` | ChatService | Messages, conversations (Firestore realtime) |
| `lib/data/services/notification_service.dart` | NotificationService | FCM push notifications |
| `lib/data/services/rating_service.dart` | RatingService | CRUD ratings |
| `lib/data/services/address_service.dart` | AddressService | User saved addresses |
| `lib/data/services/wallet_service.dart` | WalletService | Wallet balance, transactions |
| `lib/data/services/ai_service.dart` | AiService | Gemini AI diagnosis API calls |
| `lib/data/services/analytics_service.dart` | AnalyticsService | Firebase Analytics events |
| `lib/data/services/admin_service.dart` | AdminService | Admin panel data & actions |
| `lib/data/services/community_service.dart` | CommunityService | Q&A community posts |
| `lib/data/services/coupon_service.dart` | CouponService | Discount coupon validation |
| `lib/data/services/job_market_service.dart` | JobMarketService | Job listings & applications |
| `lib/data/services/storage_service.dart` | StorageService | Firebase Storage (image upload) |
| `lib/data/services/weather_service.dart` | WeatherService | Weather API for scheduling hints |

### Repositories
| File | Purpose |
|------|---------|
| `lib/data/repositories/booking_repository.dart` | Booking CRUD & filtering |
| `lib/data/repositories/rating_repository.dart` | Ratings aggregation |
| `lib/data/repositories/service_repository.dart` | Service catalog fetching |
| `lib/data/repositories/user_repository.dart` | User profile CRUD |
| `lib/data/repositories/ai_repository_impl.dart` | AI diagnosis implementation |

### Other
| File | Purpose |
|------|---------|
| `lib/data/datasources/remote/ai_remote_data_source.dart` | Raw AI API calls |
| `lib/data/seeders/test_data_seeder.dart` | Seeds Firestore with test data |

---

## 🧠 Domain — `lib/domain/`

| File | Purpose |
|------|---------|
| `lib/domain/entities/ai_diagnosis.dart` | AI diagnosis entity (clean layer) |
| `lib/domain/repositories/ai_repository.dart` | Abstract AI repo interface |

---

## 📦 Presentation — `lib/presentation/`

### Providers (State Management — ChangeNotifier) ⭐
| File | Provider | Manages |
|------|----------|---------|
| `lib/presentation/providers/auth_provider.dart` | AuthProvider | Login state, demo session, Firebase auth stream |
| `lib/presentation/providers/bookings_provider.dart` | BookingsProvider | Bookings list & CRUD |
| `lib/presentation/providers/service_request_provider.dart` | ServiceRequestProvider | New service request flow |
| `lib/presentation/providers/services_provider.dart` | ServicesProvider | Service catalog |
| `lib/presentation/providers/chat_provider.dart` | ChatProvider | Chat rooms & messages |
| `lib/presentation/providers/notification_provider.dart` | NotificationProvider | In-app notifications |
| `lib/presentation/providers/rating_provider.dart` | RatingProvider | Ratings state |
| `lib/presentation/providers/address_provider.dart` | AddressProvider | Saved addresses |
| `lib/presentation/providers/wallet_provider.dart` | WalletProvider | Wallet balance & transactions |
| `lib/presentation/providers/admin_provider.dart` | AdminProvider | Admin dashboard data |
| `lib/presentation/providers/community_provider.dart` | CommunityProvider | Community posts & answers |
| `lib/presentation/providers/job_market_provider.dart` | JobMarketProvider | Job market listings |
| `lib/presentation/providers/tech_dashboard_provider.dart` | TechDashboardProvider | Technician stats & jobs |
| `lib/presentation/providers/loyalty_provider.dart` | LoyaltyProvider | Points & rewards |
| `lib/presentation/providers/language_provider.dart` | LanguageProvider | AR/EN switching |
| `lib/presentation/providers/connectivity_provider.dart` | ConnectivityProvider | Network status |
| `lib/presentation/providers/riverpod/loyalty_pod.dart` | Riverpod pod | Loyalty (Riverpod alternative) |

### Layout ⭐
| File | Purpose |
|------|---------|
| `lib/presentation/layouts/main_layout.dart` | Shell layout with bottom nav — wraps all home screens |

### Screens

#### Auth
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/auth/login_screen.dart` | /login | Login + demo accounts + toast notifications |
| `lib/presentation/screens/auth/register_screen.dart` | /register | New user registration |

#### Home & Services
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/home/home_screen.dart` | /home | Main dashboard for clients |
| `lib/presentation/screens/services/services_screen.dart` | /services | Service catalog grid |
| `lib/presentation/screens/service_request/new_request_screen.dart` | /new-request | Create new service request |

#### Bookings & Ratings
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/bookings/bookings_screen.dart` | /bookings | Booking list & status |
| `lib/presentation/screens/ratings/add_rating_screen.dart` | /add-rating | Submit rating after service |
| `lib/presentation/screens/ratings/technician_ratings_screen.dart` | — | View technician ratings |

#### Technician Flow
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/technician/tech_dashboard_screen.dart` | /tech-dashboard | Technician home & job queue |
| `lib/presentation/screens/technician/tech_signup_screen.dart` | /tech-signup | Technician registration |
| `lib/presentation/screens/technician/tech_onboarding_screen.dart` | /tech-onboarding | Technician onboarding steps |
| `lib/presentation/screens/technician/verification_screen.dart` | /verification | ID/license verification |
| `lib/presentation/screens/technician/technician_profile_screen.dart` | — | Public technician profile |

#### Chat & Community
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/chat/chat_screen.dart` | /chat | Conversations list |
| `lib/presentation/screens/chat/chat_room_screen.dart` | — | Single chat room |
| `lib/presentation/screens/community/community_hub_screen.dart` | /community | Q&A community hub |

#### Profile & Settings
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/profile/profile_screen.dart` | /profile | User profile & settings |
| `lib/presentation/screens/settings/settings_screen.dart` | /settings | App settings |
| `lib/presentation/screens/addresses/addresses_screen.dart` | /addresses | Saved addresses list |
| `lib/presentation/screens/addresses/add_address_screen.dart` | /add-address | Add/edit address |

#### Payments & Wallet
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/wallet/wallet_screen.dart` | /wallet | Wallet balance & history |
| `lib/presentation/screens/payment/payment_methods_screen.dart` | /payment-methods | Manage payment methods |

#### Notifications & Map
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/notifications/notifications_screen.dart` | /notifications | Push notification inbox |
| `lib/presentation/screens/map/live_map_screen.dart` | /map | Live technician location map |

#### Gamification & Referral
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/gamification/loyalty_screen.dart` | /loyalty | Points, badges, rewards |
| `lib/presentation/screens/referral/referral_screen.dart` | /referral | Referral program & share |

#### Market & Store
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/job_market/job_market_screen.dart` | /job-market | Job listings for technicians |
| `lib/presentation/screens/store/store_screen.dart` | /store | Spare parts & products store |
| `lib/presentation/screens/contracts/contracts_screen.dart` | /contracts | Service contracts management |

#### Admin & Other
| File | Route | Purpose |
|------|-------|---------|
| `lib/presentation/screens/admin/admin_panel_screen.dart` | /admin | Admin control panel |
| `lib/presentation/screens/onboarding/onboarding_screen.dart` | /onboarding | First-launch onboarding |
| `lib/presentation/screens/help/help_screen.dart` | /help | Help & FAQ |
| `lib/presentation/screens/tips/tips_screen.dart` | /tips | Maintenance tips |
| `lib/presentation/screens/legal/legal_screen.dart` | /legal | Terms & Privacy Policy |

### Widgets (Reusable Components)

#### AI
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/ai/fixsy_ai_assistant_modal.dart` | AI chat assistant bottom sheet |
| `lib/presentation/widgets/ai/voice_assistant_sheet.dart` | Voice-based AI assistant |

#### Booking
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/booking/booking_modal.dart` | Book a service modal |
| `lib/presentation/widgets/booking/payment_method_selector.dart` | Payment method picker in booking flow |

#### Scheduling
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/scheduling/slot_scheduling_widget.dart` | Time slot picker (inline) |
| `lib/presentation/widgets/scheduling/slot_scheduling_modal.dart` | Time slot picker (modal) |

#### Common
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/common/skeleton_loaders.dart` | Shimmer skeleton placeholders |
| `lib/presentation/widgets/common/skeleton_loading.dart` | Generic skeleton loading widget |
| `lib/presentation/widgets/common/animated_widgets.dart` | Reusable animation wrappers |
| `lib/presentation/widgets/common/enhanced_widgets.dart` | Enhanced cards, buttons, etc. |
| `lib/presentation/widgets/common/error_widgets.dart` | Error state UI (empty, retry) |
| `lib/presentation/widgets/common/offline_indicator.dart` | No-internet banner |

#### Service Request
| File | Purpose |
|------|---------|
| `lib/presentation/screens/service_request/widgets/ai_diagnosis_widget.dart` | AI diagnosis step in request flow |
| `lib/presentation/screens/service_request/widgets/image_upload_widget.dart` | Image picker for requests |
| `lib/presentation/screens/service_request/widgets/service_selector_widget.dart` | Service type selector |

#### Other Widgets
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/message_bubble.dart` | Chat message bubble |
| `lib/presentation/widgets/chat/voice_recorder_widget.dart` | Voice recording in chat |
| `lib/presentation/widgets/rating_widgets.dart` | Star rating display & input |
| `lib/presentation/widgets/profile/profile_badges_widget.dart` | Profile badges/achievements |
| `lib/presentation/widgets/modals/ai_recommendation_modal.dart` | AI recommendation popup |
| `lib/presentation/widgets/stories/stories_widget.dart` | Stories carousel (home screen) |
| `lib/presentation/widgets/search/enhanced_search_widget.dart` | Search bar with filters |

---

## 🛣️ Routes — `lib/routes/`

| File | Purpose |
|------|---------|
| `lib/routes/app_routes.dart` | All named routes + onGenerateRoute handler ⭐ |

---

## 🔑 Key Files Quick Reference

| What I need | Where to go |
|-------------|-------------|
| Change brand colors | `lib/core/theme/app_theme.dart` |
| Add/fix login logic | `lib/presentation/screens/auth/login_screen.dart` |
| Fix auth state bug | `lib/presentation/providers/auth_provider.dart` |
| Add demo user | `lib/data/services/auth_service.dart` → demoUsers map |
| Add a new screen | Create in `lib/presentation/screens/` → register in `lib/routes/app_routes.dart` |
| Add a new API call | `lib/data/services/` → matching service file |
| Add a new state | `lib/presentation/providers/` → new provider |
| Change bottom nav | `lib/presentation/layouts/main_layout.dart` |
| Add new route | `lib/routes/app_routes.dart` |
| Add translations | `lib/core/l10n/translations_ar.dart` |
| Handle Firebase errors | `lib/core/error/app_error_handler.dart` |
| Upload images | `lib/data/services/storage_service.dart` |

---

## 🏗️ Architecture Overview

```
lib/
├── core/           ← App-wide utilities (theme, errors, utils, security)
├── data/           ← Data layer (Firebase, APIs, models, repositories)
│   ├── models/     ← Data Transfer Objects (fromJson/toJson)
│   ├── services/   ← Firebase/API calls
│   ├── repositories/ ← Business logic aggregation
│   └── seeders/    ← Dev test data
├── domain/         ← Clean architecture entities & abstract interfaces
├── presentation/   ← UI layer
│   ├── providers/  ← State management (ChangeNotifier + Riverpod)
│   ├── layouts/    ← Shell/scaffold layouts
│   ├── screens/    ← Full-page screens (organized by feature)
│   └── widgets/    ← Reusable components (organized by feature)
└── routes/         ← Centralized navigation
```

> Pattern: Provider (ChangeNotifier) → Service → Firestore/API
