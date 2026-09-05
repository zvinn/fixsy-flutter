import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/app_error_handler.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/security/security_utils.dart';
import '../../../core/theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      if (rememberMe && savedEmail != null) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password'); // Ensure password is gone if old version saved it
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Rate limiting check
    final email = SecurityUtils.sanitizeEmail(_emailController.text);
    if (SecurityUtils.isRateLimited('login:$email', maxAttempts: 5)) {
      Fluttertoast.showToast(
        msg: "محاولات كثيرة. يرجى الانتظار",
        backgroundColor: Colors.orange,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      AppLogger.info('Login attempt', data: {'email': SecurityUtils.maskEmail(email)});
      
      await context.read<AuthProvider>().signIn(
        email,
        _passwordController.text,
      );
      
      // Save credentials if Remember Me is checked
      await _saveCredentials();
      
      AppLogger.info('Login successful');
      SecurityUtils.clearRateLimit('login:$email');
      
      if (mounted) {
        Fluttertoast.showToast(
          msg: "تم تسجيل الدخول بنجاح! 🎉",
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } on AuthException catch (e) {
      AppLogger.warn('Login failed', data: {'error': e.message});
      if (mounted) {
        String message = e.message;
        if (e.message.contains('user-not-found')) {
          message = 'المستخدم غير موجود. الرجاء إنشاء حساب جديد.';
        } else if (e.message.contains('wrong-password')) {
          message = 'كلمة المرور غير صحيحة.';
        }
        
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } on NetworkException catch (e) {
      AppLogger.error('Network error during login', error: e);
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.message,
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected login error', error: e, stackTrace: stackTrace);
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppErrorHandler.getUserMessage(e),
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signInWithGoogle();
      
      if (mounted) {
        Fluttertoast.showToast(
          msg: "تم تسجيل الدخول بنجاح! 🎉",
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "خطأ في تسجيل الدخول: ${e.toString()}",
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      const SizedBox(height: 32),
                      
                      Text(
                        'Fixsy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 56, // Increased from 48
                          fontWeight: FontWeight.w900, // Heavier weight
                          color: AppTheme.primaryColor,
                          letterSpacing: -1.5,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'منصة صيانة المنازل المتكاملة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18, // Slightly larger
                          fontWeight: FontWeight.bold, // Bold for clarity
                          color: AppTheme.textPrimaryLight.withOpacity(0.8),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 48),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.validateEmail,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          hintText: 'example@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 20), // Increased from 16

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.validatePassword,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 20), // Increased from 16

                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                          const Text('تذكرني'),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      
                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    fontSize: 18, // Slightly larger
                                    fontWeight: FontWeight.w800, // Extra bold
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).scale(),
                      
                      const SizedBox(height: 16),

                      // Google Sign-In
                      if (!kIsWeb) ...[
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'أو',
                                style: TextStyle(color: Theme.of(context).disabledColor),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ).animate().fadeIn(delay: 800.ms),
                        
                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: const Icon(Icons.account_circle, size: 24),
                          label: const Text('تسجيل الدخول بواسطة Google'),
                        ).animate().fadeIn(delay: 900.ms).scale(),
                        
                        const SizedBox(height: 24),
                      ],

                      // Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontFamily: 'Cairo', // Ensure font consistency
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: 'ليس لديك حساب؟ '),
                              TextSpan(
                                text: 'سجل الآن',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
