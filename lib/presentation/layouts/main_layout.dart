import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/common/offline_indicator.dart';
import '../screens/home/home_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/community/community_hub_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/technician/tech_dashboard_screen.dart';
import '../screens/job_market/job_market_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isTechnician = authProvider.currentUser?.role == 'technician' || 
                        authProvider.currentUser?.role == 'admin';

    final List<Widget> clientPages = [
      const HomeScreen(),
      const BookingsScreen(),
      const CommunityHubScreen(),
      const ProfileScreen(),
    ];

    final List<Widget> technicianPages = [
      const TechDashboardScreen(),
      const JobMarketScreen(),
      const Center(child: Text('My Jobs')), // Placeholder
      const ProfileScreen(),
    ];

    final pages = isTechnician ? technicianPages : clientPages;

    return Scaffold(
      body: OfflineIndicator(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: AppTheme.primaryColor,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              color: Colors.grey[600],
              tabs: isTechnician 
                  ? _buildTechnicianTabs() 
                  : _buildClientTabs(),
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }

  List<GButton> _buildClientTabs() {
    return const [
      GButton(
        icon: LineIcons.home,
        text: 'الرئيسية',
      ),
      GButton(
        icon: LineIcons.calendar,
        text: 'حجوزاتي',
      ),
      GButton(
        icon: LineIcons.users,
        text: 'المجتمع',
      ),
      GButton(
        icon: LineIcons.user,
        text: 'حسابي',
      ),
    ];
  }

  List<GButton> _buildTechnicianTabs() {
    return const [
      GButton(
        icon: LineIcons.barChart,
        text: 'لوحة التحكم',
      ),
      GButton(
        icon: LineIcons.briefcase,
        text: 'سوق العمل',
      ),
      GButton(
        icon: LineIcons.tasks,
        text: 'مهامي',
      ),
      GButton(
        icon: LineIcons.user,
        text: 'حسابي',
      ),
    ];
  }
}
