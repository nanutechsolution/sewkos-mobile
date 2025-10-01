import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/pages/gues.screen.dart';
import 'package:kossumba_app/pages/guest_home_page.dart';
import 'package:kossumba_app/pages/search_page.dart';
import 'package:kossumba_app/providers/auth_provider.dart';
import 'package:kossumba_app/screens/auth_screen.dart';
import 'package:kossumba_app/screens/owner/owner_dashboard_screen.dart';
import 'package:kossumba_app/screens/profil_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late final List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _pages = [
      const GuestHomeScreen(),
      const OwnerDashboardScreen(),
      const UserProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    final authStatus = ref.read(authProvider);

    switch (index) {
      case 0: // Beranda
        setState(() {
          _selectedIndex = 0;
        });
        _pageController.animateToPage(
          _selectedIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
        break;

      case 1: // Search
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
        break;

      case 2: // Kelola / Kos Saya
        if (authStatus.token == null || authStatus.user == null) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => const AuthScreen(),
            ),
          );
          return;
        }
        setState(() {
          _selectedIndex = 1; // OwnerDashboardScreen ada di _pages[1]
        });
        _pageController.animateToPage(
          _selectedIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
        break;

      case 3: // Profil
        if (authStatus.token == null || authStatus.user == null) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => const AuthScreen(),
            ),
          );
          return;
        }
        setState(() {
          _selectedIndex = 2; // UserProfileScreen ada di _pages[2]
        });
        _pageController.animateToPage(
          _selectedIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authProvider);
    ref.read(authProvider.notifier).loadAuthStatus();

    final isOwner = authStatus.user?.name.contains('Pemilik Kos') ?? false;

    final items = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.home_filled), label: 'Beranda'),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
      BottomNavigationBarItem(
          icon: const Icon(Icons.business_center),
          label: isOwner ? 'Kelola' : 'Kos Saya'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), label: 'Profil'),
    ];
    return Scaffold(
      extendBody: true,
      appBar: _selectedIndex != 0
          ? AppBar(
              title: const Text('Sewa Kos Sumba',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blue.shade800,
              elevation: 2,
            )
          : null,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(items),
    );
  }

  Widget _buildFloatingBottomNavBar(List<BottomNavigationBarItem> items) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          items: items,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue.shade800,
          unselectedItemColor: Colors.grey.shade600,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
