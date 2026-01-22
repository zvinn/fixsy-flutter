import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/error/app_error_handler.dart';
import 'core/error/error_logger.dart';
import 'data/services/analytics_service.dart';
import 'core/utils/app_logger.dart';
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
import 'data/services/notification_service.dart' show firebaseMessagingBackgroundHandler;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize environment variables
    await EnvConfig.init();
    AppLogger.info('Environment initialized');
    
    // Initialize Firebase
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseConfig.currentPlatform,
        );
        AppLogger.info('Firebase initialized');
      } else {
        AppLogger.info('Firebase already initialized');
      }
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        AppLogger.info('Firebase already initialized (caught duplicate-app error)');
      } else {
        rethrow;
      }
    }

    // Initialize Error Handler
    await ErrorLogger.init();
    await AppErrorHandler.initialize();
    AppLogger.info('Error handler initialized');
    
    // Pass uncaught errors to ErrorLogger
    FlutterError.onError = ErrorLogger.logFlutterError;
    
    // Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    runApp(const FixsyApp());
  } catch (e, stackTrace) {
    AppLogger.fatal('App initialization failed', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

class FixsyApp extends StatelessWidget {
  const FixsyApp({super.key});

  Future<bool> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRequestProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: 'Fixsy - صيانة منازل ذكية',
            debugShowCheckedModeBanner: false,

            navigatorObservers: [
              AnalyticsService.observer,
            ],
            
            // Localization
            locale: languageProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            
            // Routes
            onGenerateRoute: AppRoutes.generateRoute,
            
            // Initial route based on auth status
            home: FutureBuilder<bool>(
              future: _checkOnboarding(),
              builder: (context, snapshot) {
                // Determine if we should show spinner
                // We show spinner if:
                // 1. FutureBuilder is waiting
                // 2. Auth provider is loading
                // 3. Language provider is loading
                
                // Get auth provider reference using Provider.of since we are inside MaterialApp
                // But wait, we can't access Provider.of here because we are establishing MaterialApp content.
                // We need to wrap 'home' in a Consumer or access context.
                
                // Correction: FutureBuilder is running. We are inside 'builder'. 
                // We can use Consumer inside FutureBuilder? No, 'authProvider' variable from line 119 in previous file 
                // was actually from an outer Consumer that I accidentally removed or need to restore.
                
                // Restoring the structure:
                return Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                     if (snapshot.connectionState == ConnectionState.waiting || 
                        authProvider.isLoading || 
                        languageProvider.isLoading) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.data == false) {
                      return const OnboardingScreen();
                    }
                    
                    return authProvider.isAuthenticated
                        ? const MainLayout()
                        : const LoginScreen();
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
