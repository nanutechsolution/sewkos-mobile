import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/helper/property_filter.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/models/room_type_price.dart';
import 'package:kossumba_app/pages/search_page.dart';
import 'package:kossumba_app/providers/property_list_provider.dart';
import 'package:kossumba_app/screens/property_detail_screen.dart';

class HomeMainContent extends ConsumerStatefulWidget {
  const HomeMainContent({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends ConsumerState<HomeMainContent> {
  String? _selectedSearchQuery;
  double? _selectedPriceMax;
  List<String> _selectedFacilities = [];
  String? _selectedCategory;
  double? _selectedLatitude;
  double? _selectedLongitude;
  double? _selectedRadius;
  Future<void> _applyFilters({
    String? searchQuery,
    double? latitude,
    double? longitude,
    double? radius,
    double? priceMax,
    List<String>? facilities,
    String? category,
  }) async {
    setState(() {
      _selectedSearchQuery = searchQuery;
      _selectedPriceMax = priceMax;
      _selectedFacilities = facilities ?? [];
      _selectedCategory = category;
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
      _selectedRadius = radius;
    });
  }

  Widget _buildSearchBar() {
    return Hero(
      tag: 'search-bar-hero',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Cari kos, homestay, atau fasilitas...',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
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

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.house, 'label': 'Kos Bulanan', 'filter': 'Kos Bulanan'},
      {'icon': Icons.bed, 'label': 'Homestay', 'filter': 'Homestay'},
      {
        'icon': Icons.beach_access,
        'label': 'Dekat Pantai',
        'filter': 'Dekat Pantai'
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Kos Harian',
        'filter': 'Kos Harian'
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Filter kategori "${cat['label']}" akan datang!'),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Icon(cat['icon'] as IconData,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    cat['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedProperties() {
    final propertyListAsyncValue = ref.watch(propertyListProvider(
      search: _selectedSearchQuery,
      priceMax: _selectedPriceMax,
      facilities: _selectedFacilities,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      radius: _selectedRadius,
      category: _selectedCategory,
    ));

    return propertyListAsyncValue.when(
      loading: () => SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 3, color: Colors.blue.shade600),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Ups, ada masalah: ${error.toString()}',
            style: TextStyle(
                color: Colors.red.shade700, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (propertyList) {
        if (propertyList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Kos tidak ditemukan. Coba filter lain?',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
          );
        }
        return SizedBox(
          height: 220, // tinggi card
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: propertyList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final property = propertyList[index];
              return SizedBox(
                width: 200, // lebar tiap card
                child: _buildPropertyCard(property),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPropertyCard(Property property) {
    String priceDisplay = 'N/A';
    if (property.roomTypes.isNotEmpty &&
        property.roomTypes[0].prices.isNotEmpty) {
      final monthlyPrice = property.roomTypes[0].prices.firstWhere(
        (p) => p.periodType == 'monthly',
        orElse: () =>
            RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0),
      );
      if (monthlyPrice.price > 0) {
        priceDisplay = 'Rp ${monthlyPrice.price.toStringAsFixed(0)} / bulan';
      } else {
        final dailyPrice = property.roomTypes[0].prices.firstWhere(
          (p) => p.periodType == 'daily',
          orElse: () =>
              RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0),
        );
        if (dailyPrice.price > 0)
          priceDisplay = 'Rp ${dailyPrice.price.toStringAsFixed(0)} / hari';
      }
    }

    Color genderColor;
    switch (property.genderPreference.toLowerCase()) {
      case 'pria':
        genderColor = Colors.blue.shade100;
        break;
      case 'wanita':
        genderColor = Colors.pink.shade100;
        break;
      case 'campur':
        genderColor = Colors.green.shade100;
        break;
      default:
        genderColor = Colors.grey.shade300;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(propertyId: property.id))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8), // hanya vertical
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  getFullImageUrl(property.images.isNotEmpty
                      ? property.images[0].imageUrl
                      : '/assets/images/no_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(priceDisplay,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          property.genderPreference.isNotEmpty
                              ? property.genderPreference
                              : 'Tidak ada preferensi',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text("Tersisa: ${property.availableRooms}",
                          style: TextStyle(
                              color: property.availableRooms > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _applyFilters(),
        edgeOffset: 0,
        child: CustomScrollView(
          slivers: [
            // Header / Hero Text
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, Selamat Datang!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Temukan kos, homestay, atau akomodasi nyaman di Sumba.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                  ],
                ),
              ),
            ),

            // Categories
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(child: _buildCategories()),
            ),
            // Section Title
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Kos Rekomendasi Untukmu',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Colors.black87),
                ),
              ),
            ),
            // Recommended Properties
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              sliver: SliverToBoxAdapter(child: _buildRecommendedProperties()),
            ),

            // Footer spacing
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
