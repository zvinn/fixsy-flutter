import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/enhanced_widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _idFrontUploaded = false;
  bool _idBackUploaded = false;
  bool _selfieUploaded = false;
  bool _isSubmitting = false;

  Future<void> _pickImage(String type) async {
    // Simulate image picking
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      if (type == 'front') _idFrontUploaded = true;
      if (type == 'back') _idBackUploaded = true;
      if (type == 'selfie') _selfieUploaded = true;
    });
  }

  Future<void> _submitVerification() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال المستندات للمراجعة بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('توثيق الهوية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(isDark),
            const SizedBox(height: 24),
            
            Text(
              'صور الهوية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildUploadCard(
                    isDark,
                    title: 'الوجه الأمامي',
                    isUploaded: _idFrontUploaded,
                    onTap: () => _pickImage('front'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadCard(
                    isDark,
                    title: 'الوجه الخلفي',
                    isUploaded: _idBackUploaded,
                    onTap: () => _pickImage('back'),
                  ),
                ),
              ],
            ).animate().slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 24),
            
            Text(
              'الصورة الشخصية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildUploadCard(
              isDark,
              title: 'صورة سيلفي مع الهوية',
              isUploaded: _selfieUploaded,
              icon: Icons.face,
              onTap: () => _pickImage('selfie'),
            ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: (_idFrontUploaded && _idBackUploaded && _selfieUploaded && !_isSubmitting)
                  ? _submitVerification
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('إرسال للمراجعة'),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'لماذا نحتاج هذا؟',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  'لضمان سلامة وموثوقية مجتمعنا، نطلب من جميع الفنيين توثيق هويتهم.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(
    bool isDark, {
    required String title,
    required bool isUploaded,
    required VoidCallback onTap,
    IconData icon = Icons.credit_card,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isUploaded
              ? Colors.green.withOpacity(0.1)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded
                ? Colors.green
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            style: isUploaded ? BorderStyle.solid : BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isUploaded
                ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                : Icon(icon, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              isUploaded ? 'تم الرفع' : title,
              style: TextStyle(
                color: isUploaded ? Colors.green : Colors.grey,
                fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
