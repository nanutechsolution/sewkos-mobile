import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Tambahkan package ini di pubspec.yaml
import 'package:intl/intl.dart'; // Untuk format mata uang

// Import dari file Anda
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/models/room_type_price.dart';
import 'package:kossumba_app/providers/property_list_provider.dart';
import 'package:kossumba_app/screens/property_detail_screen.dart';
import 'package:kossumba_app/config/config.dart';

// Definisi ulang KosSearchDelegate agar lebih rapi
class KosSearchDelegate extends SearchDelegate<String> {
  // ... (tetap sama)
  final suggestions = ['Kos Bulanan', 'Homestay', 'AC', 'Wi-Fi'];

  @override
  String? get searchFieldLabel => 'Cari kos, homestay, atau fasilitas...';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.black54),
            onPressed: () => query = '',
          )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
      onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) =>
      Center(child: Text('Hasil pencarian untuk "$query"'));

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = suggestions
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, index) => ListTile(
        title: Text(filtered[index]),
        onTap: () => close(context, filtered[index]),
      ),
    );
  }
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String? searchQuery;
  double? maxPrice;
  List<String> selectedFacilities = [];
  String? selectedCategory;

  final categories = ['Kos Bulanan', 'Kos Harian', 'Homestay', 'Dekat Pantai'];
  final facilities = ['AC', 'Wi-Fi', 'Dapur', 'Laundry'];

  @override
  Widget build(BuildContext context) {
    final propertyListAsyncValue = ref.watch(propertyListProvider(
      search: searchQuery,
      priceMax: maxPrice,
      facilities: selectedFacilities,
      category: selectedCategory,
    ));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: _buildSearchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black54),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: CustomScrollView(
          slivers: [
            // Filter cepat dalam bentuk chip
            SliverToBoxAdapter(child: _buildQuickFilters()),
            // Hasil Kos
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: propertyListAsyncValue.when(
                loading: () => _buildLoadingShimmer(),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Text('Terjadi kesalahan: ${err.toString()}'),
                  ),
                ),
                data: (properties) {
                  if (properties.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Kos tidak ditemukan. Coba filter lain?',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Hero(
      tag: 'search-bar-hero',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final result = await showSearch<String>(
              context: context,
              delegate: KosSearchDelegate(),
            );
            if (result != null) {
              setState(() {
                searchQuery = result;
              });
            }
          },
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
                    searchQuery ?? 'Cari kos, homestay, atau fasilitas...',
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

  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final selected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(cat,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.blue.shade800,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    )),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = selected ? null : cat;
                  });
                },
                selectedColor: Colors.blue.shade600,
                backgroundColor: Colors.blue.shade50,
              ),
            );
          }).toList(),
        ),
      ),
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
                    'Filter Hasil Pencarian',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter Fasilitas
                  Text('Fasilitas',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Wrap(
                    spacing: 8.0,
                    children: facilities.map((fac) {
                      final selected = selectedFacilities.contains(fac);
                      return FilterChip(
                        label: Text(fac),
                        selected: selected,
                        onSelected: (val) {
                          setStateModal(() {
                            if (val) {
                              selectedFacilities.add(fac);
                            } else {
                              selectedFacilities.remove(fac);
                            }
                          });
                          this.setState(() {}); // Update parent state
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Filter Harga
                  Text('Harga Maksimum',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Slider(
                    min: 0,
                    max: 5000000,
                    divisions: 10,
                    value: maxPrice ?? 0,
                    label: maxPrice != null
                        ? 'Rp ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(maxPrice!.toInt())}'
                        : 'Rp 0',
                    onChanged: (val) {
                      setStateModal(() {
                        maxPrice = val;
                      });
                      this.setState(() {}); // Update parent state
                    },
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Terapkan Filter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    String priceDisplay = 'N/A';
    if (property.roomTypes.isNotEmpty) {
      final monthlyPrice = property.roomTypes[0].prices.firstWhere(
        (p) => p.periodType == 'monthly',
        orElse: () =>
            RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0.0),
      );
      if (monthlyPrice.price > 0) {
        priceDisplay = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(monthlyPrice.price);
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: property.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property.images.isNotEmpty
                      ? "$apiBaseUrl/storage/${property.images[0].imageUrl}"
                      : 'https://placehold.co/100x100/E0E0E0/FFFFFF?text=No+Image',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.addressCity,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      priceDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue.shade600,
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

  Widget _buildLoadingShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        childCount: 5,
      ),
    );
  }
}
