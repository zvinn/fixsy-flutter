import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phone ?? '';
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
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      await _userRepository.updateUser(
        user.id,
        {
          'displayName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

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
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      await _userRepository.updateUserAvatar(
        userId: user.id,
        onProgress: (progress) {
          // Could show progress indicator here
        },
      );

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
      message: 'هل أنت متأكد من تسجيل الخروج؟',
    );

    if (!confirm) return;

    try {
      await context.read<AuthProvider>().signOut();
      if (!mounted) return;
      UiHelpers.showSuccessToast('تم تسجيل الخروج بنجاح');
    } catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorToast('خطأ في تسجيل الخروج');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('لا يوجد مستخدم')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF18181B),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditMode = true),
              tooltip: 'تعديل',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                    backgroundImage: user.photoURL != null
                        ? CachedNetworkImageProvider(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Colors.white,
                        onPressed: _isLoading ? null : _uploadAvatar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... (Keep existing form fields)
                      Text(
                        'المعلومات الشخصية',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      // ... (Keep name, email, phone fields)
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditMode,
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          prefixIcon: const Icon(Icons.person),
                          border: _isEditMode ? const OutlineInputBorder() : InputBorder.none,
                        ),
                        validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: user.email,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        enabled: _isEditMode,
                        decoration: InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon: const Icon(Icons.phone),
                          border: _isEditMode ? const OutlineInputBorder() : InputBorder.none,
                        ),
                      ),
                       // ... (Keep buttons)
                       if (_isEditMode) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : () { setState(() => _isEditMode = false); _loadUserData(); },
                                child: const Text('إلغاء'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updateProfile,
                                child: _isLoading ? const CircularProgressIndicator() : const Text('حفظ'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Settings & Features Links
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor),
                    title: const Text('العناوين المحفوظة'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/addresses'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet_outlined, color: Theme.of(context).primaryColor),
                    title: const Text('المحفظة'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/wallet'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.settings_outlined, color: Theme.of(context).primaryColor),
                    title: const Text('الإعدادات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                   const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                    title: const Text('المساعدة والدعم'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(context, '/help'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),


            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
