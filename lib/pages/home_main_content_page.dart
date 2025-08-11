import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/models/room_type_price.dart';
import 'package:kossumba_app/models/property.dart';
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

  final List<Map<String, String>> _promoCards = [
    {
      'imageUrl':
          'https://placehold.co/300x150/4A90E2/FFFFFF?text=Promo+Sewa+Diskon+20%',
      'title': 'Diskon Sewa 20%!',
      'subtitle': 'Hanya bulan ini, buruan cek sekarang!',
    },
    {
      'imageUrl':
          'https://placehold.co/300x150/50E3C2/FFFFFF?text=Kos+Dekat+Kampus',
      'title': 'Kos Dekat Kampus',
      'subtitle': 'Sangat cocok buat mahasiswa!',
    },
    {
      'imageUrl':
          'https://placehold.co/300x150/F5A623/FFFFFF?text=Homestay+Nyaman',
      'title': 'Homestay Nyaman',
      'subtitle': 'Fasilitas lengkap dan harga bersahabat',
    },
  ];

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Kategori Populer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Filter kategori "${cat['label']}" akan datang!')),
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
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCards() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _promoCards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final promo = _promoCards[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Promo "${promo['title']}" akan datang!')),
              );
            },
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(promo['imageUrl']!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    promo['title']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black54,
                          )
                        ]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo['subtitle']!,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
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
        height: 260,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.blue.shade600,
          ),
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
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: propertyList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final property = propertyList[index];
            return _buildPropertyCard(property);
          },
        );
      },
    );
  }

  Widget _buildPropertyCard(Property property) {
    String getFullImageUrl(String url) {
      if (url.startsWith('http')) return url;
      return 'http://$url';
    }

    String priceDisplay = 'N/A';
    if (property.roomTypes.isNotEmpty) {
      final firstRoomType = property.roomTypes[0];
      if (firstRoomType.prices.isNotEmpty) {
        final monthlyPrice = firstRoomType.prices.firstWhere(
          (p) => p.periodType == 'monthly',
          orElse: () =>
              RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0.0),
        );
        if (monthlyPrice.price > 0) {
          priceDisplay = 'Rp ${monthlyPrice.price.toStringAsFixed(0)} / bulan';
        } else {
          final dailyPrice = firstRoomType.prices.firstWhere(
            (p) => p.periodType == 'daily',
            orElse: () =>
                RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0.0),
          );
          if (dailyPrice.price > 0) {
            priceDisplay = 'Rp ${dailyPrice.price.toStringAsFixed(0)} / hari';
          }
        }
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(propertyId: property.id),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          height: 130,
          child: Row(
            children: [
              Hero(
                tag: 'property-image-${property.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 130,
                    height: 130,
                    child: Image.network(
                      property.images.isNotEmpty
                          ? getFullImageUrl(property.images[0].imageUrl)
                          : 'https://placehold.co/130x130/E0E0E0/FFFFFF?text=No+Image',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        property.addressCity,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        priceDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Fasilitas: ${property.facilities.map((f) => f.name).join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _applyFilters(),
        edgeOffset: 80,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 2,
              title: _buildSearchBar(),
              centerTitle: false,
              automaticallyImplyLeading: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              sliver: SliverToBoxAdapter(
                child: _buildCategories(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: SliverToBoxAdapter(
                child: _buildPromoCards(),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Kos Rekomendasi',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: _buildRecommendedProperties(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }
}
