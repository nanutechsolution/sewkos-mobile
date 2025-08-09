import 'package:flutter/material.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/owner_login_screen.dart';
import 'package:kossumba_app/owner_screen.dart';
import 'package:kossumba_app/owner_service.dart';
import 'package:kossumba_app/auth_service.dart';
import 'package:kossumba_app/user_profile_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<Kos>> _ownerKosListFuture;
  final String baseUrl = 'http://192.168.93.106:8000';

  @override
  void initState() {
    super.initState();
    _loadKosList();
  }

  void _loadKosList() {
    _ownerKosListFuture = OwnerService.fetchOwnerKosList().catchError((error) {
      final errStr = error.toString().toLowerCase();
      if (errStr.contains('token tidak valid') ||
          errStr.contains('tidak terautentikasi')) {
        AuthService.logout();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
        );
      }
      throw error;
    });
  }

  String getFullImageUrl(String url) {
    if (url.startsWith('/storage') || url.startsWith('/assets')) {
      return 'http://192.168.93.106:8000$url'; // ini sudah benar
    }
    // kemungkinan kamu gabung baseUrl + url yang sudah ada port
    if (url.startsWith('http://192.168.93.106:8000')) {
      return url; // jangan tambah port lagi
    }
    // fallback replace IP dan port
    return url.replaceAll(
        RegExp(r'http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?'),
        'http://192.168.93.106:8000');
  }

  Future<void> _confirmDelete(int kosId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yakin nih?'),
        content: const Text('Kamu mau hapus kos ini? Gak bisa dibalikin loh.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await OwnerService.deleteKos(kosId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil hapus kos!')),
        );
        _loadKosList();
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus kos: $e')),
        );
      }
    }
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kamu'),
        actions: [
          IconButton(
            tooltip: 'Profil Kamu',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Tambah Kos Baru',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OwnerScreen()),
              );
              _loadKosList();
              setState(() {});
            },
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Kos>>(
        future: _ownerKosListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Oops, ada masalah nih: ${snapshot.error}'),
            );
          }
          final kosList = snapshot.data;
          if (kosList == null || kosList.isEmpty) {
            return Center(
              child: Text(
                'Kamu belum punya kos yang diunggah nih.\nYuk, mulai tambah kos dulu!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: kosList.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final kos = kosList[index];
              final imageUrl = getFullImageUrl(kos.imageUrl);
              print(
                  'Debug Image URL for kos ${kos.name}: $imageUrl'); // <<< pasang debug di sini

              return ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(getFullImageUrl(kos.imageUrl)),
                  backgroundColor: Colors.grey.shade200,
                ),
                title: Text(
                  kos.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 18),
                ),
                subtitle: Text(
                  'Lokasi: ${kos.location}\nFasilitas: ${kos.facilities.join(', ')}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'Edit Kos',
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => OwnerScreen(kosToEdit: kos)),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus Kos',
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      onPressed: () => _confirmDelete(kos.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
