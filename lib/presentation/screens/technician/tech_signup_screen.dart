import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TechSignupScreen extends StatefulWidget {
  const TechSignupScreen({super.key});

  @override
  State<TechSignupScreen> createState() => _TechSignupScreenState();
}

class _TechSignupScreenState extends State<TechSignupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedSpecialty;

  final List<Map<String, dynamic>> _specialties = [
    {'id': 'plumbing', 'icon': '🔧', 'label': 'سباكة', 'color': const Color(0xFF0056D2)},
    {'id': 'electricity', 'icon': '⚡', 'label': 'كهرباء', 'color': const Color(0xFFEAB308)},
    {'id': 'carpentry', 'icon': '🪚', 'label': 'نجارة', 'color': const Color(0xFF8B5CF6)},
    {'id': 'ac', 'icon': '❄️', 'label': 'تكييف', 'color': const Color(0xFF10B981)},
    {'id': 'painting', 'icon': '🎨', 'label': 'نقاشة', 'color': const Color(0xFFEC4899)},
    {'id': 'appliances', 'icon': '📺', 'label': 'أجهزة', 'color': const Color(0xFF6366F1)},
  ];

  bool _idUploaded = false;
  int _portfolioCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Spacer(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.build, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        const Text(
                          'تسجيل فني جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'انضم لفريق فنيين Fixsy وابدأ في استقبال الطلبات',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    // Progress Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 40,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentStep >= index ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Form Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Step Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'الخطوة ${_currentStep + 1} / 3',
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Step Content
                        if (_currentStep == 0) _buildStep1(),
                        if (_currentStep == 1) _buildStep2(),
                        if (_currentStep == 2) _buildStep3(),

                        const SizedBox(height: 24),

                        // Navigation Buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _currentStep--),
                                  child: const Text('رجوع'),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _handleNext,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Icon(_currentStep == 2 ? Icons.check : Icons.arrow_forward),
                                label: Text(_currentStep == 2 ? 'إنشاء الحساب' : 'التالي'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildTextField(_nameController, 'الاسم الكامل', Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(_emailController, 'البريد الإلكتروني', Icons.email_outlined,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField(_passwordController, 'كلمة المرور', Icons.lock_outline,
            isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(_confirmPasswordController, 'تأكيد كلمة المرور', Icons.lock_outline,
            isPassword: true),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_phoneController, 'رقم الموبايل', Icons.phone_outlined,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        const Text('التخصص', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: _specialties.map((spec) {
            final isSelected = _selectedSpecialty == spec['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedSpecialty = spec['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? (spec['color'] as Color).withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? spec['color'] : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(spec['icon'], style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      spec['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? spec['color'] : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildTextField(_areaController, 'المنطقة', Icons.location_on_outlined),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        // ID Upload
        _buildUploadBox(
          icon: Icons.credit_card,
          title: 'صورة البطاقة الشخصية',
          isUploaded: _idUploaded,
          onTap: () {
            setState(() => _idUploaded = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع صورة البطاقة (محاكاة)')),
            );
          },
        ),
        const SizedBox(height: 16),

        // Portfolio Upload
        _buildUploadBox(
          icon: Icons.work_outline,
          title: 'سابقة الأعمال ($_portfolioCount/5)',
          isUploaded: _portfolioCount > 0,
          onTap: () {
            setState(() => _portfolioCount = (_portfolioCount + 1).clamp(0, 5));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع صورة (محاكاة)')),
            );
          },
        ),
        const SizedBox(height: 20),

        // Experience
        TextField(
          controller: _experienceController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'الخبرة',
            hintText: 'اكتب نبذة عن خبرتك في المجال...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }

  Widget _buildUploadBox({
    required IconData icon,
    required String title,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isUploaded ? AppTheme.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : icon,
              size: 40,
              color: isUploaded ? AppTheme.successColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              isUploaded ? 'تم الرفع ✓' : title,
              style: TextStyle(
                color: isUploaded ? AppTheme.successColor : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء حساب الفني بنجاح! 🔧')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}
