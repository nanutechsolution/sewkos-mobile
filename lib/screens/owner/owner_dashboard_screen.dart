import 'package:flutter/material.dart';
import 'package:kossumba_app/Services/auth.service.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/screens/owner/owner_login_screen.dart';
import 'package:kossumba_app/screens/property_detail_screen.dart';
import 'package:kossumba_app/services/owner_service.dart';
import 'package:kossumba_app/widgets/custom_button.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<Property>> _ownerPropertiesListFuture;

  @override
  void initState() {
    super.initState();
    _loadPropertiesList();
  }

  void _loadPropertiesList() {
    // setState(() {
    //   _ownerPropertiesListFuture =
    //       OwnerService.fetchOwnerPropertiesList().catchError((error) {
    //     final errStr = error.toString().toLowerCase();
    //     if (errStr.contains('token tidak valid') ||
    //         errStr.contains('tidak terautentikasi')) {
    //       AuthService.logout();
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
    //       );
    //     }
    //     throw error;
    //   });
    // });
  }

  String getFullImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    return '$apiBaseUrl$url';
  }

  Future<void> _confirmDelete(int propertyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yakin nih?'),
        content:
            const Text('Kamu mau hapus properti ini? Gak bisa dibalikin loh.'),
        actions: [
          CustomButton(
              text: "Batal", onPressed: () => Navigator.of(ctx).pop(false)),
          CustomButton(
              text: "Hapus", onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await OwnerService.deleteProperty(propertyId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil hapus properti!')),
        );
        _loadPropertiesList();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus properti: $e')),
        );
      }
    }
  }

  Future<void> _toggleRoomStatus(Property property) async {
    // TODO: Implementasi untuk mengubah status kamar individual atau tipe kamar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Fitur ubah status kamar individual akan datang.')),
    );
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
    );
  }

  Widget _buildPropertyItem(Property property) {
    return ListTile(
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //       builder: (_) => PropertyDetailScreen(propertyId: property.id)),
        // );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(property.images.isNotEmpty
            ? getFullImageUrl(property.images[0].imageUrl)
            : 'https://placehold.co/56x56/E0E0E0/FFFFFF?text=No+Img'),
        backgroundColor: Colors.grey.shade200,
      ),
      title: Text(
        property.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      subtitle: Text(
        'Lokasi: ${property.addressCity}\nTotal Kamar: ${property.totalRooms}, Tersedia: ${property.availableRooms}',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      isThreeLine: true,
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Ubah Status Kamar',
            icon: Icon(
              property.availableRooms > 0 ? Icons.check_circle : Icons.cancel,
              color: property.availableRooms > 0 ? Colors.green : Colors.red,
            ),
            onPressed: () => _toggleRoomStatus(property),
          ),
          IconButton(
            tooltip: 'Edit Properti',
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: () async {
              // await Navigator.of(context).push(
              //   MaterialPageRoute(
              //       builder: (_) => OwnerScreen(propertyToEdit: property)),
              // );
              _loadPropertiesList();
            },
          ),
          IconButton(
            tooltip: 'Hapus Properti',
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => _confirmDelete(property.id),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kamu'),
        actions: [
          // IconButton(
          //   tooltip: 'Profil Kamu',
          //   icon: const Icon(Icons.person_outline),
          //   onPressed: () => Navigator.of(context).push(
          //     MaterialPageRoute(builder: (_) => const UserProfileScreen()),
          //   ),
          // ),
          IconButton(
            tooltip: 'Tambah Properti Baru',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              // await Navigator.of(context).push(
              //   MaterialPageRoute(builder: (_) => const OwnerScreen()),
              // );
              _loadPropertiesList();
            },
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Property>>(
        future: _ownerPropertiesListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
              child: Text('Oops, ada masalah nih: ${snapshot.error}'),
            );
          }
          final propertiesList = snapshot.data;
          if (propertiesList == null || propertiesList.isEmpty) {
            return Center(
              child: Text(
                'Kamu belum punya properti yang diunggah nih.\nYuk, mulai tambah properti dulu!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: propertiesList.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) =>
                _buildPropertyItem(propertiesList[index]),
          );
        },
      ),
    );
  }
}
