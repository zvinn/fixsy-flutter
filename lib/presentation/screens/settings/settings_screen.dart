import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/enhanced_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false; // TODO: Connect to ThemeProvider

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLanguage = languageProvider.locale.languageCode == 'ar' ? 'العربية' : 'English';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('عام'),
          _buildListTile(
            icon: Icons.language,
            title: 'اللغة',
            subtitle: currentLanguage,
            onTap: _showLanguageDialog,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تغيير مظهر التطبيق'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
                // TODO: Update global theme
              });
            },
          ),
          const Divider(),
          _buildSectionHeader('التنبيهات'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('تفعيل التنبيهات'),
            subtitle: const Text('استلام إشعارات العروض والتحديثات'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          _buildSectionHeader('أخرى'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'عن التطبيق',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'سياسة الخصوصية',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'الشروط والأحكام',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final currentLocale = context.read<LanguageProvider>().locale.languageCode;
        return AlertDialog(
          title: const Text('اختر اللغة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('العربية'),
                trailing: currentLocale == 'ar'
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  context.read<LanguageProvider>().changeLanguage(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: currentLocale == 'en'
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  context.read<LanguageProvider>().changeLanguage(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
