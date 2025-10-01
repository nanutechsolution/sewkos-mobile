import 'package:flutter/material.dart';
import 'package:kossumba_app/pages/gues.screen.dart';
import 'package:kossumba_app/screens/login_page.dart';
import 'package:kossumba_app/screens/profilku_screen.dart';
import 'package:kossumba_app/services/auth.service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late Future<bool> _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = _checkLogin();
  }

  Future<bool> _checkLogin() async {
    final user = await AuthService.getUserFromStorage();
    return user != null; // true kalau ada user tersimpan
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(
      index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              const GuestHomeScreen(),
              const Center(child: Text('Halaman Peta')),
              const Center(child: Text('Halaman Favorit')),
              isLoggedIn ? const ProfileScreens() : const LoginPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pin_drop_rounded),
                label: 'Sekitar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Favorit',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF667eea),
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 8,
          ),
        );
      },
    );
  }
}
