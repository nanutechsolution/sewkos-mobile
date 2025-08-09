import 'package:flutter/material.dart';
import 'package:kossumba_app/auth_check_screen.dart';
import 'package:kossumba_app/favorite_screen.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/kos_detail_screen.dart';
import 'package:kossumba_app/kos_service.dart';
import 'package:kossumba_app/location_search_dialog.dart';
import 'package:kossumba_app/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Kos>> _kosListFuture;

  String? _selectedLocation;
  double? _priceMax;
  List<String> _selectedFacilities = [];

  @override
  void initState() {
    super.initState();
    _fetchKosList();
  }

  Future<void> _fetchKosList({
    String? searchQuery,
    double? latitude,
    double? longitude,
    double? radius,
    double? priceMax,
    List<String>? facilities,
  }) async {
    setState(() {
      _kosListFuture = KosService.getKosList(
        search: searchQuery,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        status: 'kosong',
        priceMax: priceMax,
        facilities: facilities,
      );
    });
  }

  void _showFilterBottomSheet() {
    String? tempSearchQuery = _selectedLocation;
    double? tempPriceMax = _priceMax;
    List<String> tempFacilities = List.from(_selectedFacilities);

    double? tempLatitude;
    double? tempLongitude;
    double? tempRadius;
    String? tempName;

    final TextEditingController searchController =
        TextEditingController(text: tempSearchQuery);
    final TextEditingController priceController =
        TextEditingController(text: tempPriceMax?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // supaya bisa scroll penuh
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text('Filter Pencarian',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('Cari Nama/Lokasi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: searchController,
                      onChanged: (value) => tempSearchQuery = value,
                      decoration: const InputDecoration(
                          hintText: 'Misalnya: Kos Bintang'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Map<String, dynamic>? result =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (_) => const LocationSearchDialog(),
                        );
                        if (result != null) {
                          setState(() {
                            tempLatitude = result['latitude'];
                            tempLongitude = result['longitude'];
                            tempRadius = result['radius'];
                            tempName = result['name'];
                          });
                        }
                      },
                      icon: const Icon(Icons.location_on),
                      label: Text(
                        tempLatitude != null && tempLongitude != null
                            ? 'Lokasi terpilih: "${_extractName(tempName)}" (Radius: ${tempRadius?.toStringAsFixed(0)} km)'
                            : 'Cari Berdasarkan Jangkauan',
                      ),
                    ),
                    if (tempLatitude != null && tempLongitude != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Sedang mencari kos di sekitar "${_extractName(tempName)}" dengan radius ${tempRadius?.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text('Harga Maksimum',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: priceController,
                      onChanged: (value) =>
                          tempPriceMax = double.tryParse(value),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Misalnya: 600000'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Fasilitas',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Wi-Fi'),
                      value: tempFacilities.contains('Wi-Fi'),
                      onChanged: (bool? val) {
                        setState(() {
                          val == true
                              ? tempFacilities.add('Wi-Fi')
                              : tempFacilities.remove('Wi-Fi');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('AC'),
                      value: tempFacilities.contains('AC'),
                      onChanged: (bool? val) {
                        setState(() {
                          val == true
                              ? tempFacilities.add('AC')
                              : tempFacilities.remove('AC');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Dapur Bersama'),
                      value: tempFacilities.contains('Dapur Bersama'),
                      onChanged: (bool? val) {
                        setState(() {
                          val == true
                              ? tempFacilities.add('Dapur Bersama')
                              : tempFacilities.remove('Dapur Bersama');
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          child: const Text('Terapkan'),
                          onPressed: () {
                            _selectedLocation = tempSearchQuery;
                            _priceMax = tempPriceMax;
                            _selectedFacilities = tempFacilities;

                            _fetchKosList(
                              searchQuery: tempSearchQuery,
                              latitude: tempLatitude,
                              longitude: tempLongitude,
                              radius: tempRadius,
                              priceMax: tempPriceMax,
                              facilities: tempFacilities,
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _extractName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return '';
    if (fullName.contains(',')) {
      return fullName.split(',')[0].trim();
    }
    return fullName.split(' ')[0].trim();
  }

  void _showFilterDialog() {
    String? tempSearchQuery = _selectedLocation;
    double? tempPriceMax = _priceMax;
    List<String> tempFacilities = List.from(_selectedFacilities);

    double? tempLatitude;
    double? tempLongitude;
    double? tempRadius;
    String? tempName;

    final TextEditingController searchController =
        TextEditingController(text: tempSearchQuery);
    final TextEditingController priceController =
        TextEditingController(text: tempPriceMax?.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Pencarian'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Cari Nama/Lokasi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: searchController,
                      onChanged: (value) => tempSearchQuery = value,
                      decoration: const InputDecoration(
                          hintText: 'Misalnya: Kos Bintang'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Map<String, dynamic>? result =
                            await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (_) => const LocationSearchDialog(),
                        );
                        if (result != null) {
                          setState(() {
                            tempLatitude = result['latitude'] as double?;
                            tempLongitude = result['longitude'] as double?;
                            tempRadius = result['radius'] as double?;
                            tempName = result['name'] as String?;
                          });
                        }
                      },
                      icon: const Icon(Icons.location_on),
                      label: Text(
                        tempLatitude != null && tempLongitude != null
                            ? 'Lokasi terpilih: "${_extractName(tempName)}" (Radius: ${tempRadius?.toStringAsFixed(0)} km)'
                            : 'Cari Berdasarkan Jangkauan',
                      ),
                    ),
                    if (tempLatitude != null && tempLongitude != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Sedang mencari kos di sekitar "${_extractName(tempName)}" dengan radius ${tempRadius?.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text('Harga Maksimum',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: priceController,
                      onChanged: (value) =>
                          tempPriceMax = double.tryParse(value),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'Misalnya: 600000'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Fasilitas',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Wi-Fi'),
                      value: tempFacilities.contains('Wi-Fi'),
                      onChanged: (bool? val) {
                        setState(() {
                          val == true
                              ? tempFacilities.add('Wi-Fi')
                              : tempFacilities.remove('Wi-Fi');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('AC'),
                      value: tempFacilities.contains('AC'),
                      onChanged: (bool? val) {
                        setState(() {
                          val == true
                              ? tempFacilities.add('AC')
                              : tempFacilities.remove('AC');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Dapur Bersama'),
                      value: tempFacilities.contains('Dapur Bersama'),
                      onChanged: (bool? val) {
                        setState(() {
                          val == true
                              ? tempFacilities.add('Dapur Bersama')
                              : tempFacilities.remove('Dapur Bersama');
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _selectedLocation = tempSearchQuery;
                _priceMax = tempPriceMax;
                _selectedFacilities = tempFacilities;

                _fetchKosList(
                  searchQuery: tempSearchQuery,
                  latitude: tempLatitude,
                  longitude: tempLongitude,
                  radius: tempRadius,
                  priceMax: tempPriceMax,
                  facilities: tempFacilities,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Terapkan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.house, 'label': 'Kos Bulanan'},
      {'icon': Icons.bed, 'label': 'Homestay'},
      {'icon': Icons.beach_access, 'label': 'Dekat Pantai'},
      {'icon': Icons.calendar_today, 'label': 'Kos Harian'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Populer',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade700,
                  child: Icon(cat['icon'] as IconData,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildKosCard(Kos kos) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => KosDetailScreen(kosId: kos.id)),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: Image.network(
                    getFullImageUrl(kos.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 110,
                        color: Colors.grey.shade400),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kos.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        kos.location,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        kos.price,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      Text(
                        'Fasilitas: ${kos.facilities.join(', ')}',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedKos() {
    return FutureBuilder<List<Kos>>(
      future: _kosListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator(strokeWidth: 3)));
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red))),
          );
        } else if (snapshot.hasData) {
          final kosList = snapshot.data!;
          if (kosList.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(20),
              child:
                  Text('Kos tidak ditemukan.', style: TextStyle(fontSize: 16)),
            ));
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: kosList.length,
            itemBuilder: (context, index) => _buildKosCard(kosList[index]),
          );
        }
        return const SizedBox();
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosSumba',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            tooltip: 'Tambah Kos',
            onPressed: () async {
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthCheckScreen()));
              _fetchKosList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoriteScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterBottomSheet,
        icon: const Icon(Icons.filter_alt),
        label: const Text('Filter'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchKosList(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildCategories(),
            const SizedBox(height: 30),
            const Text(
              'Kos Rekomendasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecommendedKos(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
