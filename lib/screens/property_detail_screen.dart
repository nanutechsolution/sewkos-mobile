import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/helper/property_filter.dart';
import 'package:kossumba_app/models/property_image.dart';
import 'package:kossumba_app/models/room_type.dart';
import 'package:kossumba_app/providers/property_detail_provider.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final int propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final propertyDetailAsyncValue =
        ref.watch(PropertyDetailProvider(widget.propertyId));

    return propertyDetailAsyncValue.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Terjadi Kesalahan')),
        body: Center(child: Text('Error: ${error.toString()}')),
      ),
      data: (property) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(property),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildInfoSection('Alamat',
                        '${property.addressStreet}, ${property.addressCity}, ${property.addressProvince}'),
                    const SizedBox(height: 16),
                    _buildActionButton(
                        Icons.navigation, 'Mulai Navigasi', Colors.green, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Fitur navigasi segera hadir!')),
                      );
                    }),
                    const SizedBox(height: 24),
                    _buildPropertyDetails(property),
                    const SizedBox(height: 24),
                    _buildImageGallery('Foto Properti', property.images),
                    const SizedBox(height: 24),
                    _buildFacilityList('Fasilitas Umum',
                        property.facilities.map((e) => e.name).toList()),
                    const SizedBox(height: 32),
                    _buildRoomTypes(property.roomTypes),
                    const SizedBox(height: 32),
                    _buildReviewsSection(),
                    const SizedBox(height: 24),
                    _buildActionButton(
                        Icons.phone, 'Hubungi Pemilik', Colors.blueAccent, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Fitur hubungi pemilik segera hadir!')),
                      );
                    }),
                    const SizedBox(height: 40),
                    _buildReviewFormPlaceholder(),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =================== WIDGETS ===================

  Widget _buildSliverAppBar(property) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              getFullImageUrl(property.images.isNotEmpty
                  ? property.images[0].imageUrl
                  : '/assets/images/no_image.png'),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image,
                    size: 80, color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  stops: const [0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          property.name,
          style: const TextStyle(fontWeight: FontWeight.bold, shadows: [
            Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 1))
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur favorit segera hadir!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(content,
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPropertyDetails(property) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Detail Properti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDetailRow('Tipe Kos', property.genderPreference),
          _buildDetailRow(
              'Tahun Dibangun', property.yearBuilt?.toString() ?? '-'),
          _buildDetailRow('Total Kamar', property.totalRooms.toString()),
          _buildDetailRow('Kamar Tersedia', property.availableRooms.toString()),
          if (property.managerName != null ||
              property.managerPhone != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Pengelola',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildDetailRow('Nama', property.managerName ?? '-'),
            _buildDetailRow('Telepon', property.managerPhone ?? '-'),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow('Catatan', property.notes ?? '-'),
          const Text('Deskripsi & Peraturan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(property.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Peraturan: ${property.rules ?? 'Tidak ada peraturan khusus.'}',
              style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w400))),
        ],
      ),
    );
  }

  Widget _buildImageGallery(String title, List<PropertyImage> images) {
    if (images.isEmpty) return const Text('Belum ada foto properti.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final imgUrl = "$apiBaseUrl/storage/${images[index].imageUrl}";
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imgUrl,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityList(String title, List<String> facilities) {
    if (facilities.isEmpty) return const Text('Belum ada fasilitas umum.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: facilities
              .map((f) => Chip(
                  label: Text(f),
                  backgroundColor: Colors.blue.shade100,
                  avatar: const Icon(Icons.check, color: Colors.blue)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRoomTypes(List<RoomType> roomTypes) {
    if (roomTypes.isEmpty) return const Text('Belum ada tipe kamar.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipe Kamar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...roomTypes.map(
          (rt) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rt.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Deskripsi', rt.description ?? '-'),
                    _buildDetailRow(
                        'Ukuran', '${rt.sizeM2?.toStringAsFixed(1) ?? '-'} m2'),
                    _buildDetailRow('Total Kamar', rt.totalRooms.toString()),
                    _buildDetailRow('Tersedia', rt.availableRooms.toString()),
                    const SizedBox(height: 12),
                    const Text('Harga',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...rt.prices.map(
                      (price) => _buildDetailRow(
                          price.periodType.replaceAll('_', ' ').toTitleCase(),
                          'Rp ${price.price.toStringAsFixed(0)}'),
                    ),
                    const SizedBox(height: 12),
                    _buildFacilityList('Fasilitas Kamar',
                        rt.facilities.map((f) => f.name).toList()),
                    const SizedBox(height: 12),
                    const Text('Kamar Individual',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ...rt.rooms.map((room) => _buildDetailRow(
                        '${room.roomNumber} (Lantai ${room.floor ?? "-"})',
                        room.status.toUpperCase())),
                  ]),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildReviewsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Ulasan & Rating',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Belum ada ulasan untuk properti ini.'),
        ],
      );

  Widget _buildReviewFormPlaceholder() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Kirim Ulasan Anda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Formulir ulasan akan segera hadir!'),
        ],
      );
}

extension StringExtension on String {
  String toTitleCase() {
    return replaceAll(RegExp(' +'), ' ')
        .split(' ')
        .map((str) => str.isNotEmpty
            ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
