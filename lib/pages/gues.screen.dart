import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/models/room_type_price.dart';
import 'package:kossumba_app/providers/property_list_provider.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/screens/owner/property_detail_screen.dart';
import 'package:kossumba_app/services/auth.service.dart';
import 'package:shimmer/shimmer.dart';

class GuestHomeScreen extends ConsumerStatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  ConsumerState<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends ConsumerState<GuestHomeScreen> {
  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) {
      return 'Selamat Pagi! $name 🌅';
    } else if (hour >= 10 && hour < 15) {
      return 'Selamat Siang! $name👋';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore! $name 🌇';
    } else {
      return 'Selamat Malam! $name 🌙';
    }
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 200,
      pinned: true, // biar appbar tetap nempel di atas
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        background: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: AuthService.getUserFromStorage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final user = snapshot.data!;
                    return Text(
                      _getGreeting(user.name),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  } else {
                    return Text(
                      _getGreeting("Pecari Kos"),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Temukan kos impianmu dengan mudah.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(context), // search bar di expanded state
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56), // tinggi search bar
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSearchBar(context), // search bar tampil juga saat shrink
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Cari kos, lokasi, atau nama...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true, // lebih rapat
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _showFilterSheet(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea), // warna brand ungu/gradient
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Text(
          "Filter Pencarian",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        // Filter harga
        ListTile(
          title: const Text("Harga per bulan"),
          subtitle: RangeSlider(
            values: const RangeValues(500000, 2000000),
            min: 0,
            max: 5000000,
            divisions: 50,
            labels: const RangeLabels("Rp500k", "Rp2jt"),
            onChanged: (values) {
              // update state
            },
          ),
        ),

        // Jarak
        ListTile(
          title: const Text("Jarak"),
          trailing: DropdownButton<String>(
            items: ["<1 km", "1-3 km", "3-5 km", ">5 km"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {},
          ),
        ),

        // Fasilitas
        ListTile(
          title: const Text("Fasilitas"),
          subtitle: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                  label: const Text("WiFi"),
                  selected: false,
                  onSelected: (_) {}),
              FilterChip(
                  label: const Text("AC"), selected: false, onSelected: (_) {}),
              FilterChip(
                  label: const Text("Dapur"),
                  selected: false,
                  onSelected: (_) {}),
              FilterChip(
                  label: const Text("Parkiran"),
                  selected: false,
                  onSelected: (_) {}),
            ],
          ),
        ),

        // Jenis kos
        ListTile(
          title: const Text("Jenis Kos"),
          trailing: DropdownButton<String>(
            items: ["Campur", "Putra", "Putri"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {},
          ),
        ),

        // Urutkan
        ListTile(
          title: const Text("Urutkan"),
          trailing: DropdownButton<String>(
            items: ["Termurah", "Termahal", "Terbaru", "Rating Tertinggi"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {},
          ),
        ),

        const SizedBox(height: 20),

        // Tombol apply
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup bottom sheet
            },
            child: const Text("Terapkan Filter"),
          ),
        )
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7, // tinggi awal
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildFilters(context),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyListAsyncValue = ref.watch(propertyListProvider());

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(propertyListProvider());
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: propertyListAsyncValue.when(
                loading: () => _buildLoadingShimmer(),
                error: (err, stack) =>
                    Center(child: Text('Error: ${err.toString()}')),
                data: (properties) {
                  final kosPilihan = properties
                      .where((kos) => kos.reviews.any((e) => e.rating > 4.5))
                      .toList();

                  final kosDiskon = properties
                      .where((kos) => kos.roomTypes
                          .any((room) => room.prices.any((p) => p.price > 0)))
                      .toList();

                  final kosTerbaru = properties
                      .where((kos) =>
                          kos.roomTypes.any((room) => room.availableRooms > 0))
                      .toList()
                      .reversed
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kos Pilihan untukmu',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: kosPilihan.length,
                            itemBuilder: (context, index) {
                              return SimpleKosCard(kos: kosPilihan[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Kos dengan Diskon',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: kosDiskon.isNotEmpty ? 280 : 50,
                          child: kosDiskon.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: kosDiskon.length,
                                  itemBuilder: (context, index) {
                                    return DiscountKosCard(
                                        kos: kosDiskon[index]);
                                  },
                                )
                              : Center(
                                  child: Text('Belum ada kos dengan diskon.',
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600)),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Text('Kos Terbaru',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: kosTerbaru.length,
                            itemBuilder: (context, index) {
                              return SimpleKosCard(kos: kosTerbaru[index]);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 250, child: _buildShimmerList()),
          const SizedBox(height: 24),
          SizedBox(height: 280, child: _buildShimmerList()),
          const SizedBox(height: 24),
          SizedBox(height: 250, child: _buildShimmerList()),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

class SimpleKosCard extends StatefulWidget {
  final Property kos;

  const SimpleKosCard({super.key, required this.kos});

  @override
  State<SimpleKosCard> createState() => _SimpleKosCardState();
}

class _SimpleKosCardState extends State<SimpleKosCard> {
  bool _isFavorite = false;

  String _formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    String priceDisplay = 'N/A';
    if (widget.kos.roomTypes.isNotEmpty &&
        widget.kos.roomTypes[0].prices.isNotEmpty) {
      final monthlyPrice = widget.kos.roomTypes[0].prices.firstWhere(
        (p) => p.periodType == 'monthly',
        orElse: () =>
            RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0),
      );
      if (monthlyPrice.price > 0) {
        priceDisplay = 'Rp ${monthlyPrice.price.toStringAsFixed(0)} / bulan';
      } else {
        final dailyPrice = widget.kos.roomTypes[0].prices.firstWhere(
          (p) => p.periodType == 'daily',
          orElse: () =>
              RoomTypePrice(id: 0, roomTypeId: 0, periodType: '', price: 0),
        );
        if (dailyPrice.price > 0)
          priceDisplay = 'Rp ${dailyPrice.price.toStringAsFixed(0)} / hari';
      }
    }
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      PropertyDetailScreen(propertyId: widget.kos.id))),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      widget.kos.images.isNotEmpty
                          ? apiBaseUrl + widget.kos.images[0].imageUrl
                          : 'https://placehold.co/400x300',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.kos.genderPreference,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kos.name,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.kos.addressStreet,
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCurrency(priceDisplay.isNotEmpty
                              ? int.tryParse(priceDisplay
                                      .replaceAll('Rp ', '')
                                      .replaceAll(' / bulan', '')
                                      .replaceAll(' / hari', '')) ??
                                  0
                              : 0),
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            Text(
                              '${widget.kos.reviews.isNotEmpty ? widget.kos.reviews.first.rating : 0}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
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
}

class DiscountKosCard extends StatefulWidget {
  final Property kos;

  const DiscountKosCard({super.key, required this.kos});

  @override
  State<DiscountKosCard> createState() => _DiscountKosCardState();
}

class _DiscountKosCardState extends State<DiscountKosCard> {
  bool _isFavorite = false;

  String _formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyPrice = widget.kos.roomTypes.first.prices.firstWhere(
      (p) => p.periodType == 'monthly',
    );
    int newPrice = widget.kos.roomTypes.first.prices
            .firstWhere(
              (p) => p.periodType == 'monthly',
            )
            .price *
        (100 - 10) ~/
        100;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => PropertyDetailScreen(kosData: widget.kos),
            //   ),
            // );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      widget.kos.images.isNotEmpty
                          ? apiBaseUrl + widget.kos.images[0].imageUrl
                          : 'https://placehold.co/400x300',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Diskon 10%',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.kos.genderPreference,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kos.name,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.kos.addressCity,
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatCurrency(newPrice),
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            Text(
                              _formatCurrency(
                                  int.tryParse(monthlyPrice.price.toString()) ??
                                      0),
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            // Text(
                            //   '${widget.kos.reviews.firstWhere((element) => element.id == widget.kos.id).rating}',
                            //   style: GoogleFonts.poppins(
                            //       fontSize: 12, color: Colors.black54),
                            // ),
                          ],
                        ),
                      ],
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
}
