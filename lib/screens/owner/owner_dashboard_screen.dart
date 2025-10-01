import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kossumba_app/helper/property_filter.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/screens/owner/owner_login_screen.dart';
import 'package:kossumba_app/screens/owner/owner_screen.dart';
import 'package:kossumba_app/screens/owner/property_detail_screen.dart';
import 'package:kossumba_app/services/api_service.dart';
import 'package:kossumba_app/services/auth.service.dart';
import 'package:kossumba_app/services/owner_service.dart';
import 'package:shimmer/shimmer.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<Property>> _ownerPropertiesListFuture;
  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  String _searchQuery = '';
  String _roomStatusFilter = 'Semua'; // Semua, Tersedia, Penuh

  @override
  void initState() {
    super.initState();
    _loadPropertiesList();
  }

  void _loadPropertiesList() {
    setState(() {
      _ownerPropertiesListFuture =
          OwnerService.fetchOwnerPropertiesList().then((list) {
        _allProperties = list;
        _applyFilter();
        return list;
      }).catchError((error) {
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
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredProperties = _allProperties.where((property) {
        final matchesName =
            property.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = (_roomStatusFilter == 'Semua') ||
            (_roomStatusFilter == 'Tersedia' && property.availableRooms > 0) ||
            (_roomStatusFilter == 'Penuh' && property.availableRooms == 0);
        return matchesName && matchesStatus;
      }).toList();
    });
  }

  void _confirmAndDeleteProperty(BuildContext context, int propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Properti?'),
          content:
              const Text('Apakah Anda yakin ingin menghapus properti ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog
              child: const Text('Batal'),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Capture the navigator before async gap
                final navigator = Navigator.of(context);

                try {
                  await OwnerService.deleteProperty(propertyId);
                  OwnerService.fetchOwnerPropertiesList().then((list) {
                    setState(() {
                      _allProperties = list;
                    });
                  });
                  // Check if widget is still mounted
                  if (!mounted) return;
                  navigator.pop(); // Tutup dialog
                  // Tampilkan SnackBar sukses jika perlu
                } catch (e) {
                  if (!mounted) return;

                  navigator.pop(); // Tutup dialog
                  // Tampilkan SnackBar error
                }
              },
            ),
          ],
        );
      },
    );
  }
// Di dalam class _OwnerDashboardScreenState

  Future<void> _editProperty(Property property) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detailedProperty = await ApiService.getPropertyDetail(property.id);
      if (detailedProperty.images.isNotEmpty) {}
      // Pastikan widget masih terpasang (mounted) sebelum menggunakan context
      if (!mounted) return;

      Navigator.of(context).pop();

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OwnerScreen(propertyToEdit: detailedProperty),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail properti: $e')),
      );
    }
  }

  Future<void> _toggleRoomStatus(Property property) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Fitur ubah status kamar individual akan datang.')),
    );
  }

  Widget _buildPropertyItem(Property property) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(propertyId: property.id),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            getFullImageUrl(property.images.isNotEmpty
                ? property.images[0].imageUrl
                : '/assets/images/no_image.png'),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          property.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Lokasi: ${property.addressCity}\nKamar: ${property.availableRooms}/${property.totalRooms}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 2,
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
              onPressed: () => _editProperty(property),
            ),
            IconButton(
              tooltip: 'Hapus Properti',
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () => _confirmAndDeleteProperty(context, property.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(width: 60, height: 60, color: Colors.white),
          ),
          title: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(height: 14, color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(height: 12, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(height: 12, width: 100, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<String> options = ['Semua', 'Tersedia', 'Penuh'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: options.map((option) {
          final isSelected = _roomStatusFilter == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _roomStatusFilter = option;
                  _applyFilter();
                });
              },
              selectedColor: const Color(0xFF2979FF),
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Cari nama properti...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              _searchQuery = val;
              _applyFilter();
            },
          ),
        ),
        _buildFilterChips(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadPropertiesList(),
        child: FutureBuilder<List<Property>>(
          future: _ownerPropertiesListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerList();
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Oops, ada masalah nih: ${snapshot.error}'),
              );
            }
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Properti',
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const OwnerScreen()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text('Tambah Kos', style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFilterBar(),
                Expanded(
                  child: _filteredProperties.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada properti sesuai filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredProperties.length,
                          itemBuilder: (context, index) =>
                              _buildPropertyItem(_filteredProperties[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
