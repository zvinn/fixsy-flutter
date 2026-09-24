import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/loyalty_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userRepository});
  final UserRepository? userRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserRepository? _customRepo;
  UserRepository get _userRepository => widget.userRepository ?? (_customRepo ??= UserRepository());
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    try {
      final user = Provider.of<AuthProvider?>(context, listen: false)?.currentUser;
      if (user != null) {
        _nameController.text = user.displayName;
        _phoneController.text = user.phone ?? '';
      } else {
        _nameController.text = 'أحمد سامي';
        _phoneController.text = '01012345678';
      }
    } catch (_) {
      _nameController.text = 'أحمد سامي';
      _phoneController.text = '01012345678';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider?>(context, listen: false)?.currentUser;
      if (user != null) {
        await _userRepository.updateUser(
          user.id,
          {
            'displayName': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
        );
      }

      if (!mounted) return;

      setState(() => _isEditMode = false);
      UiHelpers.showSuccessToast('تم تحديث الملف الشخصي بنجاح!');
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorToast('خطأ في التحديث: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadAvatar() async {
    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider?>(context, listen: false)?.currentUser;
      if (user != null) {
        await _userRepository.updateUserAvatar(
          userId: user.id,
          onProgress: (progress) {},
        );
      }

      if (!mounted) return;
      UiHelpers.showSuccessToast('تم تحديث الصورة الشخصية!');
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorToast(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await UiHelpers.showConfirmationDialog(
      context,
      title: 'تسجيل الخروج',
      message: 'هل أنت متأكد من تسجيل الخروج من حسابك؟',
    );

    if (!confirm) return;
    if (!mounted) return;

    try {
      await Provider.of<AuthProvider?>(context, listen: false)?.signOut();
      if (!mounted) return;
      UiHelpers.showSuccessToast('تم تسجيل الخروج بنجاح');
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorToast('خطأ في تسجيل الخروج');
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await UiHelpers.showConfirmationDialog(
      context,
      title: 'حذف الحساب نهائياً',
      message: 'تحذير: هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟ سيتم حذف جميع بياناتك وسجل طلباتك ورصيد محفظتك ولا يمكن التراجع عن هذا الإجراء.',
    );

    if (!confirm) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider?>(context, listen: false)?.currentUser;
      if (user != null) {
        await _userRepository.deleteUser(user.id);
      }
      if (!mounted) return;
      await Provider.of<AuthProvider?>(context, listen: false)?.signOut();
      if (!mounted) return;
      UiHelpers.showSuccessToast('تم حذف الحساب بنجاح');
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorToast('خطأ أثناء حذف الحساب: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showReferralDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_rounded, color: Colors.purple),
            SizedBox(width: 8),
            Text('تطبيق كود إحالة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل كود الإحالة الذي حصلت عليه من صديق للحصول على 20 ج.م في محفظتك فوراً!',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'مثال: FRIEND50',
                labelText: 'كود الإحالة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
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
            onPressed: () {
              final val = codeCtrl.text.trim().toUpperCase();
              if (val.isEmpty) return;
              Navigator.pop(ctx);
              UiHelpers.showSuccessToast('تم تطبيق الكود $val بنجاح! أضيفت 20 ج.م لمحفظتك 🎉');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('تطبيق الكود', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider?>(context);
    final user = auth?.currentUser;

    final displayName = user?.displayName ?? (_nameController.text.isNotEmpty ? _nameController.text : 'أحمد سامي');
    final email = user?.email ?? 'ahmed.samy@fixsy.com';
    final photoUrl = user?.photoURL;
    final role = user?.role ?? 'client';

    final wallet = Provider.of<WalletProvider?>(context);
    final address = Provider.of<AddressProvider?>(context);
    final loyalty = Provider.of<LoyaltyProvider?>(context);

    final walletBalance = wallet?.balance ?? 1250.0;
    final addressCount = address?.addresses.length ?? 2;
    final loyaltyPoints = loyalty?.points ?? 1450;
    final loyaltyTier = loyalty != null ? 'الفئة ${loyalty.levelName} ⭐' : 'الفئة الذهبية ⭐';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (!_isEditMode)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => setState(() => _isEditMode = true),
                tooltip: 'تعديل البيانات',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              // User Avatar and Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                            backgroundImage: photoUrl != null
                                ? CachedNetworkImageProvider(photoUrl)
                                : null,
                            child: photoUrl == null
                                ? const Icon(Icons.person, size: 48, color: AppTheme.primaryColor)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 16),
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                                onPressed: _isLoading ? null : _uploadAvatar,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: role == 'tech' ? Colors.orange.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: role == 'tech' ? Colors.orange.shade200 : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            role == 'tech' ? Icons.engineering : Icons.verified_user_rounded,
                            size: 14,
                            color: role == 'tech' ? Colors.orange.shade800 : Colors.blue.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            role == 'tech' ? 'فني صيانة معتمد' : 'عميل معتمد لدى Fixsy',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: role == 'tech' ? Colors.orange.shade900 : Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Gamification & Loyalty VIP Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loyaltyTier,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$loyaltyPoints نقطة Fixsy مكافآت',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'استبدل نقاطك بخصم على طلبات الصيانة القادمة',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Personal Information / Edit Form Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المعلومات الشخصية',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditMode,
                        decoration: InputDecoration(
                          labelText: 'الاسم بالكامل',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: _isEditMode ? const OutlineInputBorder() : InputBorder.none,
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: email,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        enabled: _isEditMode,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: _isEditMode ? const OutlineInputBorder() : InputBorder.none,
                        ),
                      ),
                      if (_isEditMode) ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() => _isEditMode = false);
                                        _loadUserData();
                                      },
                                child: const Text('إلغاء'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text('حفظ التعديلات', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action List Tiles
              Material(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Colors.blue, size: 20),
                      ),
                      title: const Text('العناوين المحفوظة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('$addressCount عناوين مسجلة', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/addresses'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.green, size: 20),
                      ),
                      title: const Text('المحفظة والمدفوعات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('الرصيد: ${walletBalance.toInt()} ج.م', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/wallet'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.credit_card_rounded, color: Colors.teal, size: 20),
                      ),
                      title: const Text('طرق الدفع والبطاقات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('البطاقات المحفوظة ووسائل الدفع', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/payment-methods'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.card_giftcard_rounded, color: Colors.purple, size: 20),
                      ),
                      title: const Text('دعوة الأصدقاء والمكافآت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('كودك: FIXSY50 • تطبيق كود', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: _showReferralDialog,
                            child: const Text('إدخال كود', style: TextStyle(fontSize: 12, color: Colors.purple)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.purple),
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: 'FIXSY50'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم نسخ كود الدعوة بنجاح! 🎉')),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(context, '/referral'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.indigo, size: 20),
                      ),
                      title: const Text('الإعدادات العامة واللغة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('اللغة، التنبيهات، المظهر', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                      ),
                      title: const Text('نصائح وإرشادات الصيانة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('مقالات وفيديوهات توعوية للأجهزة المنزلية', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/tips'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.help_outline_rounded, color: Colors.orange, size: 20),
                      ),
                      title: const Text('المساعدة والدعم الفني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('الأسئلة الشائعة وتواصل مع فريق الدعم', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/help'),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.policy_outlined, color: Colors.blueGrey, size: 20),
                      ),
                      title: const Text('الشروط والأحكام والسياسات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text('سياسة الخصوصية وشروط الاستخدام والضمان', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.pushNamed(context, '/legal'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Role Switching / Tech Promotion Banner
              if (role == 'client')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'هل أنت فني صيانة محترف؟',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'انضم لشبكة فنيي Fixsy واستقبل طلبات الصيانة وضاعف دخلك',
                              style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/tech-signup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('انضم كفني', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              else if (role == 'tech')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'لوحة تحكم الفني',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'إدارة الطلبات، الأرباح، التوثيق، وساعات العمل',
                              style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/tech-dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('دخول اللوحة', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Danger Zone: Logout and Delete Account
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.red.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, color: Colors.red),
                        label: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _deleteAccount,
                        icon: Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red.shade400),
                        label: Text(
                          'حذف الحساب نهائياً',
                          style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
