import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/models/room_type.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/providers/property_detail_provider.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final int propertyId;

  PropertyDetailScreen({super.key, required this.propertyId});

  String _formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  final Map<String, IconData> _facilityIcons = {
    'wifi': Icons.wifi_rounded,
    'ac': Icons.ac_unit_rounded,
    'kamar mandi dalam': Icons.shower_rounded,
    'bathroom': Icons.shower_rounded, // sinonim
    'parkir motor': Icons.motorcycle_rounded,
    'dapur bersama': Icons.kitchen_rounded,
    'view pantai': Icons.beach_access_rounded,
    'tv': Icons.tv_rounded,
    'gym': Icons.fitness_center_rounded,
    'arsitektur unik': Icons.house_rounded,
    'kasur': Icons.bed_rounded,
    'meja belajar': Icons.chair_rounded,
    'interior': Icons.chair_alt_rounded,
    'cover': Icons.home_rounded,
  };

  IconData _getFacilityIcon(String facility) {
    final key = facility.toLowerCase().trim();
    return _facilityIcons[key] ?? Icons.check_circle_outline_rounded;
  }

  // Fungsi untuk menampilkan modal bottom sheet pemesanan
  void _showBookingSheet(BuildContext context, RoomType roomData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Ringkasan Pemesanan',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Informasi Ringkasan
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      (roomData.images.first.imageUrl.isNotEmpty
                          ? apiBaseUrl + roomData.images.first.imageUrl
                          : 'https://picsum.photos/60'),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://picsum.photos/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  title: Text(roomData.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Text(roomData.description.toString(),
                      style: GoogleFonts.poppins(fontSize: 12)),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Ukuran Kamar', '${roomData.sizeM2} m²'),
                _buildSummaryRow('Harga',
                    _formatCurrency(roomData.prices.first.price.toInt())),
                const Divider(height: 32),
                _buildSummaryRow('Total Pembayaran',
                    _formatCurrency(roomData.prices.first.price.toInt()),
                    isTotal: true),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pemesanan berhasil!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Lanjutkan Pembayaran',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsyncValue = ref.watch(PropertyDetailProvider(propertyId));

    return propertyAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (kosData) {
        final List<String> facilitiesList = (kosData.roomTypes)
            .expand((room) => room.images.map((e) => e.type))
            .cast<String>()
            .toSet()
            .toList();
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, kosData),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoSection(context, kosData),
                          const SizedBox(height: 24),
                          _buildDescriptionSection(kosData),
                          const SizedBox(height: 24),
                          _buildFacilitiesSection(facilitiesList),
                          const SizedBox(height: 24),
                          _buildRoomTypesSection(context, kosData),
                          const SizedBox(height: 24),
                          _buildHouseRulesSection(kosData),
                          const SizedBox(height: 24),
                          _buildLocationMapSection(),
                          const SizedBox(height: 24),
                          _buildHostSection(context, kosData),
                          const SizedBox(height: 24),
                          _buildReviewsSection(context, kosData),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildFloatingActionButtons(context, kosData),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Property kosData) {
    final List<String> images = kosData.images.map((e) => e.imageUrl).toList();
    final PageController pageController = PageController();

    return SliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  apiBaseUrl + images[index],
                  fit: BoxFit.cover,
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: images.length,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    type: WormType.thin,
                    activeDotColor: Colors.white,
                    dotColor: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black45,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Property kosData) {
    final monthlyPrices = kosData.roomTypes
        .expand((r) => r.prices)
        .where((p) => p.periodType == 'monthly');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                kosData.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${kosData.reviews.map((e) => e.rating).reduce((a, b) => a + b) / kosData.reviews.length} (${kosData.reviews.length} ulasan)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              kosData.addressCity,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.group_rounded, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            Text(
              'Kos ${kosData.genderPreference}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Mulai dari ${_formatCurrency(
            monthlyPrices.isNotEmpty
                ? monthlyPrices
                    .reduce((a, b) => a.price < b.price ? a : b)
                    .price
                    .toInt()
                : 0,
          )} / bulan',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.primary, // 🔥 ambil dari tema
              ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Property kosData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          kosData.description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection(List<String> facilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fasilitas Umum',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: facilities.map((fac) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getFacilityIcon(fac),
                    color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  fac,
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomTypesSection(BuildContext context, Property kosData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Kamar',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...kosData.roomTypes
            .map((room) => _buildRoomTypeCard(context, room))
            .toList(),
      ],
    );
  }

  Widget _buildRoomTypeCard(BuildContext context, RoomType room) {
    final bool isAvailable = room.availableRooms > 0;
    final List<String> roomImages = room.images.map((e) => e.imageUrl).toList();
    final List<String> roomFacilities =
        room.facilities.map((e) => e.name).toList();
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              itemCount: roomImages.length,
              itemBuilder: (context, index) {
                return Flexible(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      roomImages[index].isEmpty
                          ? 'https://picsum.photos/60'
                          : apiBaseUrl + roomImages[index],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://picsum.photos/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.green.shade600
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAvailable
                            ? 'Tersedia ${room.availableRooms} kamar'
                            : 'Penuh',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatCurrency(10000),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.fullscreen_rounded,
                        color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Ukuran: ${room.sizeM2} m2',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Fasilitas:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: roomFacilities.map((fac) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getFacilityIcon(fac),
                            color: Colors.blue.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text(fac, style: GoogleFonts.poppins(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (isAvailable)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isAvailable ? () {/* aksi pesan */} : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Pesan Sekarang',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseRulesSection(Property kosData) {
    final List<String> rules =
        kosData.rules!.split('.').where((r) => r.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peraturan Kos',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rules
                  .map((rule) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$rule.',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi Kos',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            color: Colors.grey.shade300,
            child: Center(
              child: Text(
                'Tampilan Peta',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHostSection(BuildContext context, Property kosData) {
    final bool isLoggedIn = false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://placehold.co/100x100/png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemilik Kos',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  kosData.managerName.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // if (isLoggedIn)
          // Row(
          //   children: [
          //     IconButton(
          //       icon: const Icon(Icons.chat_bubble_outline_rounded,
          //           color: Colors.blue),
          //       onPressed: () async {
          //         final String whatsappNumber = kosData.managerPhone;
          //         final String message =
          //             'Halo, saya ingin bertanya tentang kos ${kosData.name}.';
          //         final Uri whatsappUri = Uri.parse(
          //             'whatsapp://send?phone=$whatsappNumber&text=$message');
          //         if (await canLaunchUrl(whatsappUri)) {
          //           await launchUrl(whatsappUri);
          //         } else {
          //           ScaffoldMessenger.of(context).showSnackBar(
          //             const SnackBar(
          //                 content: Text('Tidak dapat membuka WhatsApp.')),
          //           );
          //         }
          //       },
          //     ),
          //     IconButton(
          //       icon: const Icon(Icons.phone_rounded, color: Colors.green),
          //       onPressed: () async {
          //         final String phoneNumber = kosData.managerPhone.toString();
          //         final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
          //         if (await canLaunchUrl(phoneUri)) {
          //           await launchUrl(phoneUri);
          //         } else {
          //           ScaffoldMessenger.of(context).showSnackBar(
          //             const SnackBar(
          //                 content: Text('Tidak dapat melakukan panggilan.')),
          //           );
          //         }
          //       },
          //     ),
          //   ],
          // )
          // ElevatedButton(
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //           content:
          //               Text('Silakan login untuk menghubungi pemilik.')),
          //     );
          //   },
          //   child: Text('Login', style: GoogleFonts.poppins(fontSize: 12)),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue.shade600,
          //     foregroundColor: Colors.white,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10)),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, Property kosData) {
    final List<Map<String, dynamic>> reviews = kosData.reviews
        .map((e) => {
              'user': e.authorName,
              'rating': e.rating,
              'comment': e.comment,
            })
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Ulasan Penyewa',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menulis ulasan...')),
                    );
                  },
                  child: Text(
                    'Tulis Ulasan',
                    style: GoogleFonts.poppins(color: Colors.blue.shade600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Aksi untuk melihat semua ulasan
                  },
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(color: Colors.blue.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Rating summary
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                reviews.isNotEmpty
                    ? '${reviews.first['rating']} (${reviews.length} ulasan)'
                    : 'Belum ada ulasan',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // List of reviews
        ...reviews.map((review) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            NetworkImage('https://placehold.co/100x100/png'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          review['user'],
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            List.generate(review['rating'] as int, (index) {
                          return const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review['comment'],
                    style: GoogleFonts.poppins(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        if (reviews.isEmpty)
          Text(
            'Belum ada ulasan untuk kos ini.',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, Property kosData) {
    final bool isAvailable = kosData.availableRooms > 0;
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isAvailable
                  ? () {
                      final roomData = kosData.roomTypes.first;
                      _showBookingSheet(context, roomData);
                    }
                  : null,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                'Pesan Sekarang',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable
                    ? Theme.of(context).colorScheme.primary // Warna utama tema
                    : Theme.of(context)
                        .colorScheme
                        .surfaceVariant, // Warna abu soft dari tema
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary, // Text di atas primary
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
