import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// Sample Data untuk contoh
final List<Map<String, dynamic>> searchResultsData = [
  {
    'id': 1,
    'nama': 'Kos Sumba Indah',
    'alamat': 'Jl. Diponegoro No. 15, Waikabubak',
    'harga': 800000,
    'rating': 4.8,
    'image': 'https://picsum.photos/200/150?random=10'
  },
  {
    'id': 2,
    'nama': 'Kos Pantai Biru',
    'alamat': 'Jl. Pantai Kodi No. 8, Kodi',
    'harga': 1200000,
    'rating': 4.9,
    'image': 'https://picsum.photos/200/150?random=20'
  },
  {
    'id': 3,
    'nama': 'Kos Mahasiswa Ceria',
    'alamat': 'Jl. Pendidikan No. 22, Waikabubak',
    'harga': 600000,
    'rating': 4.6,
    'image': 'https://picsum.photos/200/150?random=30'
  },
];

class SearchPages extends StatefulWidget {
  const SearchPages({super.key});

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = LatLng(-9.6669, 120.2520);
  LatLng _selectedPosition = LatLng(-9.6669, 120.2520);
  double _radius = 5.0;
  bool _isMapVisible = false;

  final List<String> _facilities = ['WiFi', 'AC', 'Kamar Mandi Dalam'];
  final List<String> _selectedFacilities = [];
  RangeValues _priceRange = const RangeValues(0, 5000000);

  @override
  void initState() {
    super.initState();
    _selectedPosition = _initialPosition;
  }

  void _onMapTapped(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _selectedPosition = latLng;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Izin lokasi ditolak.');
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedPosition, 15);
      });
      _showSnackBar('Lokasi Anda ditemukan.');
    } catch (e) {
      _showSnackBar('Gagal mendapatkan lokasi.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateModal) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter Lanjutan',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Harga per Bulan'),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 5000000,
                    divisions: 20,
                    onChanged: (RangeValues values) {
                      setStateModal(() {
                        _priceRange = values;
                      });
                      setState(() {});
                    },
                  ),
                  Center(
                    child: Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(_priceRange.start)} - Rp ${NumberFormat('#,##0', 'id_ID').format(_priceRange.end)}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Fasilitas'),
                  Wrap(
                    spacing: 8.0,
                    children: _facilities.map((fac) {
                      final isSelected = _selectedFacilities.contains(fac);
                      return FilterChip(
                        label: Text(fac),
                        selected: isSelected,
                        onSelected: (val) {
                          setStateModal(() {
                            if (val) {
                              _selectedFacilities.add(fac);
                            } else {
                              _selectedFacilities.remove(fac);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: _buildSearchBar(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black54),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tampilan Peta
          if (_isMapVisible)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _initialPosition,
                zoom: 12.0,
                onTap: _onMapTapped,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kossumba_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                      point: _selectedPosition,
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedPosition,
                      radius: _radius * 1000,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              ],
            ),

          // Daftar Hasil Kos di bawah peta
          if (!_isMapVisible)
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildFilterChips(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _buildResultsList(searchResultsData),
                  ),
                ],
              ),
            ),

          // Tombol Aksi di kanan bawah
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'map-toggle',
                  onPressed: () {
                    setState(() {
                      _isMapVisible = !_isMapVisible;
                    });
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade600,
                  child:
                      Icon(_isMapVisible ? Icons.view_list : Icons.map_rounded),
                ),
                const SizedBox(height: 8),
                if (_isMapVisible)
                  FloatingActionButton(
                    heroTag: 'gps-button',
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade600,
                    child: const Icon(Icons.my_location_rounded),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Hero(
      tag: 'search-bar-hero',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cari kos...',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _facilities.map((fac) {
          final isSelected = _selectedFacilities.contains(fac);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(fac,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.blue.shade800,
                  )),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedFacilities.add(fac);
                  } else {
                    _selectedFacilities.remove(fac);
                  }
                });
              },
              selectedColor: Colors.blue.shade600,
              backgroundColor: Colors.blue.shade50,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResultsList(List<Map<String, dynamic>> properties) {
    if (properties.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Kos tidak ditemukan.'),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildPropertyCard(properties[index]),
        childCount: properties.length,
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> kos) {
    String priceDisplay =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(kos['harga']);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
              child: Image.network(
                kos['image'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kos['nama'],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(kos['alamat'],
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${kos['rating']}',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      priceDisplay,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
