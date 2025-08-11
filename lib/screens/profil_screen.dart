import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/Screens/home_screen.dart.dart';
import 'package:kossumba_app/screens/auth_screen.dart';
import 'package:kossumba_app/services/auth.service.dart';
import 'package:kossumba_app/providers/auth_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);

    if (authStatus.token == null || authStatus.user == null) {
      return const AuthScreen();
    }

    final user = authStatus.user!;
    final userName = user.name;
    final userEmail = user.email;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              // Avatar dengan bayangan halus
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade400,
                  child:
                      const Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),

              // Nama user - bold dan besar
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),

              // Email - lebih kecil dan warna abu lembut
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              // Menu list dengan card putih + shadow
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuTile(
                      context,
                      icon: Icons.settings,
                      title: 'Pengaturan Akun',
                      subtitle: 'Ubah info akun & password',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Pengaturan Akun belum tersedia')),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.privacy_tip,
                      title: 'Privasi & Keamanan',
                      subtitle: 'Atur preferensi privasi',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Privasi & Keamanan belum tersedia')),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Bantuan & Dukungan',
                      subtitle: 'FAQ dan hubungi kami',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Bantuan & Dukungan belum tersedia')),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi dan info lainnya',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tentang Aplikasi belum tersedia')),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Tombol logout full width dan jelas
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService.logout();
                        ref.read(authProvider.notifier).state = AuthState();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
