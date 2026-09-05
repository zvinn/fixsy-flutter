import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart' as p;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/env_config.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'routes/app_routes.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/services_provider.dart';
import 'presentation/providers/bookings_provider.dart';
import 'presentation/providers/service_request_provider.dart';
import 'presentation/providers/rating_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/connectivity_provider.dart';
import 'presentation/providers/loyalty_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/layouts/main_layout.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/technician/tech_dashboard_screen.dart';

enum AppFlavor { client, technician }

class FixsyAppConfig {
  final AppFlavor flavor;
  final String appTitle;

  FixsyAppConfig({
    required this.flavor,
    required this.appTitle,
  });
}

class SharedAppRunner {
  static Future<void> run(FixsyAppConfig config) async {
    WidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.init();
    
    // Initialize things... (simplified for brevity)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
      }
    } catch (_) {}

    runApp(
      ProviderScope(
        child: FixsyApp(config: config), // Wrapped for Riverpod support
      ),
    );
  }
}

class FixsyApp extends StatelessWidget {
  final FixsyAppConfig config;
  const FixsyApp({super.key, required this.config});

  Future<bool> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(create: (_) => LanguageProvider()),
        p.ChangeNotifierProvider(create: (_) => AuthProvider()),
        p.ChangeNotifierProvider(create: (_) => ServicesProvider()),
        p.ChangeNotifierProvider(create: (_) => BookingsProvider()),
        p.ChangeNotifierProvider(create: (_) => ServiceRequestProvider()),
        p.ChangeNotifierProvider(create: (_) => RatingProvider()),
        p.ChangeNotifierProvider(create: (_) => NotificationProvider()..initialize()),
        p.ChangeNotifierProvider(create: (_) => ChatProvider()),
        p.ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        p.ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
      ],
      child: p.Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: config.appTitle,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            onGenerateRoute: AppRoutes.generateRoute,
            home: FutureBuilder<bool>(
              future: _checkOnboarding(),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                // Flavor specific logic
                if (config.flavor == AppFlavor.client) {
                   if (snapshot.data == false) return const OnboardingScreen();
                }
                
                return p.Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (!auth.isAuthenticated) return const LoginScreen();
                    
                    // Route based on flavor
                    if (config.flavor == AppFlavor.technician) {
                      return const TechDashboardScreen(); 
                    }
                    return const MainLayout();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
