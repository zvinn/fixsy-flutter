import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/app_error_handler.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/security/security_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

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
        msg: 'محاولات كثيرة. يرجى الانتظار',
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
          msg: 'تم تسجيل الدخول بنجاح! 🎉',
          backgroundColor: AppTheme.successColor,
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } on AuthException catch (e) {
      AppLogger.warn('Login failed', data: {'error': e.message});
      if (mounted) {
        var message = e.message;
        if (e.message.contains('user-not-found')) {
          message = 'المستخدم غير موجود. الرجاء إنشاء حساب جديد.';
        } else if (e.message.contains('wrong-password')) {
          message = 'كلمة المرور غير صحيحة.';
        }
        
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: AppTheme.errorColor,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } on NetworkException catch (e) {
      AppLogger.error('Network error during login', error: e);
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.message,
          backgroundColor: AppTheme.errorColor,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected login error', error: e, stackTrace: stackTrace);
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppErrorHandler.getUserMessage(e),
          backgroundColor: AppTheme.errorColor,
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
          msg: 'تم تسجيل الدخول بنجاح! 🎉',
          backgroundColor: AppTheme.successColor,
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'خطأ في تسجيل الدخول: ${e.toString()}',
          backgroundColor: AppTheme.errorColor,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signInWithApple();
      
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'تم تسجيل الدخول بواسطة Apple بنجاح! 🍏',
          backgroundColor: Colors.green,
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'خطأ في تسجيل الدخول بواسطة Apple: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDemoLogin(String role) async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signInDemo(role);
      
      if (mounted) {
        final roleName = role == 'client' ? 'العميل' : (role == 'tech' ? 'الفني' : 'المدير');
        Fluttertoast.showToast(
          msg: 'تم الدخول كـ $roleName التجريبي بنجاح! 🚀',
          backgroundColor: AppTheme.successColor,
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: e.toString(),
          backgroundColor: AppTheme.errorColor,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين كلمة المرور', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور:',
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'example@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                Fluttertoast.showToast(msg: 'يرجى إدخال بريد إلكتروني صالح');
                return;
              }
              Navigator.pop(ctx);
              try {
                await context.read<AuthProvider>().resetPassword(email);
                Fluttertoast.showToast(
                  msg: 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني ✉️',
                  backgroundColor: Colors.green,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('إرسال الرابط'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6F8FD), Color(0xFFE9F0F9)], // Soft premium light background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo & Header
                          const SizedBox(height: 8),
                          Text(
                            'Fixsy',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                              letterSpacing: -1.5,
                            ),
                          ).animate().fadeIn(duration: 600.ms, curve: Curves.easeOutQuad).slideY(begin: -0.2, end: 0),
                          
                          const SizedBox(height: 8),
                          Text(
                            'منصة صيانة المنازل المتكاملة',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight.withOpacity(0.6),
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2, end: 0),
                          
                          const SizedBox(height: 48),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: Validators.validateEmail,
                            style: GoogleFonts.cairo(fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              hintText: 'example@email.com',
                              labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
                              prefixIcon: const Icon(LucideIcons.mail, size: 20, color: AppTheme.primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            validator: Validators.validatePassword,
                            style: GoogleFonts.cairo(fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              labelStyle: GoogleFonts.cairo(color: Colors.grey.shade600),
                              prefixIcon: const Icon(LucideIcons.lock, size: 20, color: AppTheme.primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
                          
                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() => _rememberMe = value ?? false);
                                    },
                                    activeColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  Text('تذكرني', style: GoogleFonts.cairo(fontSize: 14)),
                                ],
                              ),
                              TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                child: const Text('نسيت كلمة المرور؟'),
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms),
                          
                          const SizedBox(height: 24),

                          // Login Button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryColor, Color(0xFF2A5298)], // Assuming primary is blueish
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'تسجيل الدخول',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
                          
                          const SizedBox(height: 24),

                          // Social Sign-In (Google & Apple)
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'أو الدخول عبر',
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                            ],
                          ).animate().fadeIn(delay: 800.ms),
                          
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: Colors.grey.shade200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(LucideIcons.chrome, size: 20, color: Colors.red),
                                  label: Text('Google', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : _handleAppleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: Colors.grey.shade200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(LucideIcons.apple, size: 20, color: Colors.black),
                                  label: Text('Apple', style: GoogleFonts.inter(color: Colors.black87, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.95, 0.95)),
                          
                          const SizedBox(height: 32),

                          // Quick Demo Access
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.zap, size: 16, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      'دخول تجريبي سريع',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppTheme.primaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                                          ),
                                        ),
                                        onPressed: _isLoading ? null : () => _handleDemoLogin('client'),
                                        child: Text('عميل', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppTheme.primaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                                          ),
                                        ),
                                        onPressed: _isLoading ? null : () => _handleDemoLogin('tech'),
                                        child: Text('فني', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppTheme.primaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                                          ),
                                        ),
                                        onPressed: _isLoading ? null : () => _handleDemoLogin('admin'),
                                        child: Text('مدير', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 1000.ms),

                          const SizedBox(height: 16),

                          // Register Link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.register);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                  ),
                                  children: [
                                    const TextSpan(text: 'ليس لديك حساب؟ '),
                                    TextSpan(
                                      text: 'سجل الآن',
                                      style: GoogleFonts.cairo(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 1100.ms),
                        ],
                      ),
                    ),
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
