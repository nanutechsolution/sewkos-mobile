import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/pages/home_main_content_page.dart';
import 'package:kossumba_app/providers/auth_provider.dart';
import 'package:kossumba_app/screens/auth_screen.dart';
import 'package:kossumba_app/screens/profil_screen.dart';
import 'package:kossumba_app/screens/property_screen.dart';

// --- HomeScreen Utama yang Mengelola BottomNavigationBar ---
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // Widget tetap, nanti diganti dinamis di build()
  final List<Widget> _widgetOptions = [
    const HomeMainContent(),
    const Center(child: Text('Halaman Cari (Belum diimplementasi)')),
    Container(),
    const Center(child: Text('Halaman Chat (Belum diimplementasi)')),
    Container(),
  ];

  void _onItemTapped(int index) {
    if (index == 4 || index == 2) {
      final authStatus = ref.read(authProvider);
      if (authStatus.token == null || authStatus.user == null) {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false, // biar backgroundnya transparan
            pageBuilder: (_, __, ___) => const AuthScreen(),
          ),
        );
        return; // Jangan ganti tab kalau belum login
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authProvider);
    ref.read(authProvider.notifier).loadAuthStatus();

    // Ganti widget Profil kalau sudah login
    List<Widget> widgets = List.from(_widgetOptions);
    if (authStatus.token != null && authStatus.user != null) {
      widgets[4] = const UserProfileScreen();
    } else {
      widgets[4] = Container();
    }

    // Label Kos Saya dinamis: ganti ke 'Kelola' kalau role = owner
    final isOwner = authStatus.user?.name.contains('Pemilik Kos') ?? false;

    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
      BottomNavigationBarItem(
          icon: const Icon(Icons.business),
          label: isOwner ? 'Kelola' : 'Kos Saya'),
      const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sewa Kos Sumba',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            tooltip: 'Notifikasi',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur notifikasi akan datang!')),
              );
            },
          ),
        ],
      ),
      body: widgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
