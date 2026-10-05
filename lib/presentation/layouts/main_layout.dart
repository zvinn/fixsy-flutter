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
    final isTechnician = authProvider.currentUser?.isTechnician == true || 
                        authProvider.currentUser?.isAdmin == true;

    final clientPages = <Widget>[
      const HomeScreen(),
      const BookingsScreen(),
      const CommunityHubScreen(),
      const ProfileScreen(),
    ];

    final technicianPages = <Widget>[
      const TechDashboardScreen(),
      const JobMarketScreen(),
      const BookingsScreen(),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.12), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              offset: const Offset(0, -4),
              color: const Color(0xFF0F172A).withOpacity(0.06),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: GNav(
              rippleColor: AppTheme.primaryLight.withOpacity(0.1),
              hoverColor: const Color(0xFFF1F5F9),
              gap: 8,
              activeColor: AppTheme.primaryColor,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              duration: const Duration(milliseconds: 350),
              tabBackgroundColor: AppTheme.primaryLight.withOpacity(0.12),
              color: const Color(0xFF64748B),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
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
