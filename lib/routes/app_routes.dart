import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/layouts/main_layout.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/bookings/bookings_screen.dart';
import '../presentation/screens/services/services_screen.dart';
import '../presentation/screens/service_request/new_request_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/addresses/addresses_screen.dart';
import '../presentation/screens/addresses/add_address_screen.dart';
import '../presentation/screens/wallet/wallet_screen.dart';
import '../presentation/screens/help/help_screen.dart';
import '../presentation/screens/tips/tips_screen.dart';
import '../presentation/screens/legal/legal_screen.dart';
import '../presentation/screens/technician/tech_dashboard_screen.dart';
import '../presentation/screens/technician/tech_signup_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import '../presentation/screens/community/community_hub_screen.dart';
import '../presentation/screens/map/live_map_screen.dart';
import '../presentation/screens/admin/admin_panel_screen.dart';
import '../presentation/screens/referral/referral_screen.dart';
import '../presentation/screens/payment/payment_methods_screen.dart';
import '../presentation/screens/job_market/job_market_screen.dart';
import '../presentation/screens/technician/tech_onboarding_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/gamification/loyalty_screen.dart';
import '../presentation/screens/technician/verification_screen.dart';

/// App Routes Configuration
/// Centralized routing for the entire application
class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String services = '/services';
  static const String newRequest = '/new-request';
  static const String settings = '/settings';
  static const String addresses = '/addresses';
  static const String addAddress = '/add-address';
  static const String wallet = '/wallet';
  static const String help = '/help';
  static const String tips = '/tips';
  static const String legal = '/legal';
  static const String techDashboard = '/tech-dashboard';
  static const String jobMarket = '/job-market';
  static const String techSignup = '/tech-signup';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String communityHub = '/community';
  static const String liveMap = '/live-map';
  static const String adminPanel = '/admin';
  static const String referral = '/referral';
  static const String paymentMethods = '/payment-methods';
  static const String onboarding = '/onboarding';
  static const String loyalty = '/loyalty';
  static const String verification = '/verification';
  static const String techOnboarding = '/tech-onboarding';
  static const String store = '/store';
  static const String contracts = '/contracts';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const MainLayout());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case bookings:
        return MaterialPageRoute(builder: (_) => const BookingsScreen());
      
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen());
      
      case newRequest:
        return MaterialPageRoute(builder: (_) => const NewRequestScreen());
      
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case addresses:
        return MaterialPageRoute(builder: (_) => const AddressesScreen());

      case addAddress:
        return MaterialPageRoute(builder: (_) => const AddAddressScreen());
      
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      
      case help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      
      case tips:
        return MaterialPageRoute(builder: (_) => const TipsScreen());
      
      case legal:
        return MaterialPageRoute(builder: (_) => const LegalScreen());
      
      case techDashboard:
        return MaterialPageRoute(builder: (_) => const TechDashboardScreen());
      
      case jobMarket:
        return MaterialPageRoute(builder: (_) => const JobMarketScreen());
      
      case techSignup:
        return MaterialPageRoute(builder: (_) => const TechSignupScreen());
      
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      
      case communityHub:
        return MaterialPageRoute(builder: (_) => const CommunityHubScreen());
      
      case liveMap:
        return MaterialPageRoute(builder: (_) => const LiveMapScreen());
      
      case adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminPanelScreen());
      
      case referral:
        return MaterialPageRoute(
          builder: (_) => const ReferralScreen(userId: 'user123'),
        );
      
      case paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case loyalty:
        return MaterialPageRoute(builder: (_) => const LoyaltyScreen());
      
      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());

      case techOnboarding:
        return MaterialPageRoute(builder: (_) => const TechOnboardingScreen());
      
      case store:
        return MaterialPageRoute(builder: (_) => const StoreScreen());

      case contracts:
        return MaterialPageRoute(builder: (_) => const ContractsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation helpers
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToBookings(BuildContext context) {
    Navigator.pushNamed(context, bookings);
  }

  static void navigateToServices(BuildContext context) {
    Navigator.pushNamed(context, services);
  }

  static void navigateToNewRequest(BuildContext context) {
    Navigator.pushNamed(context, newRequest);
  }
}
