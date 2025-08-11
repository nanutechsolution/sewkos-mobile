import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/providers/auth_provider.dart';
import 'package:kossumba_app/screens/auth_screen.dart'; // misal ada screen login

class KosSayaScreen extends ConsumerWidget {
  const KosSayaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Belum login
    if (authState.token == null || authState.user == null) {
      return _buildLoginChoice(context);
    }

    // Sudah login - cek role user (ganti sesuai struktur user)
    final user = authState.user!;
    final isOwner = true; // Contoh flag, sesuaikan dengan data user

    if (isOwner) {
      return _buildManageKosPage(user);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pencari Kos'),
          backgroundColor: Colors.blue.shade800,
        ),
        body: const Center(
          child: Text(
            'Halaman khusus pencari kos belum tersedia',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }

  Widget _buildLoginChoice(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Silakan masuk untuk mengelola kos Anda atau mencari kos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_search),
              label: const Text('Masuk sebagai Pencari Kos'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.business),
              label: const Text('Masuk sebagai Pemilik Kos'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageKosPage(user) {
    return Scaffold(
      body: Center(
        child: Text(
          'Selamat datang, ${user.name}! Kelola kos Anda di sini.',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
