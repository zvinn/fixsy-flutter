import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'customer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      UiHelpers.showSuccessToast('تم إنشاء الحساب بنجاح!');
      Navigator.pop(context); // Go back to login or home
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorToast(e.toString());
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
        appBar: AppBar(
          title: const Text('إنشاء حساب جديد'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome text
                      Text(
                        'مرحباً بك في Fixsy',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 8),
                      
                      // Welcome text with Quick Fill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'أنشئ حسابك للبدء',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 8),
                          // Admin Quick Fill
                          IconButton(
                            icon: const Icon(Icons.flash_on, size: 20, color: Colors.amber),
                            tooltip: 'ملء بيانات الأدمن',
                            onPressed: () {
                              setState(() {
                                _nameController.text = 'Admin User';
                                _emailController.text = 'mhamed.saad.ibrahim@gmail.com';
                                _passwordController.text = 'Admin@Fixsy2026';
                                _confirmPasswordController.text = 'Admin@Fixsy2026';
                                _selectedRole = 'technician';
                              });
                              UiHelpers.showSuccessToast('تم ملء بيانات الأدمن ⚡');
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      
                      const SizedBox(height: 32),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكامل',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          if (value.length < 3) {
                            return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 16),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني';
                          }
                          if (!value.contains('@')) {
                            return 'البريد الإلكتروني غير صالح';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال كلمة المرور';
                          }
                          if (value.length < 6) {
                            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 16),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'تأكيد كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء تأكيد كلمة المرور';
                          }
                          if (value != _passwordController.text) {
                            return 'كلمات المرور غير متطابقة';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 24),

                      // Role selection
                      Text(
                        'نوع الحساب',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _RoleCard(
                              title: 'عميل',
                              value: 'customer',
                              groupValue: _selectedRole,
                              onChanged: (value) => setState(() => _selectedRole = value),
                              icon: Icons.person,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoleCard(
                              title: 'فني',
                              value: 'technician',
                              groupValue: _selectedRole,
                              onChanged: (value) => setState(() => _selectedRole = value),
                              icon: Icons.engineering,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 800.ms).scale(),
                      
                      const SizedBox(height: 32),

                      // Register button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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
                                  'إنشاء حساب',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 16),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
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

class _RoleCard extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final Function(String) onChanged;
  final IconData icon;

  const _RoleCard({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Theme.of(context).iconTheme.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
