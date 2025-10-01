import 'package:flutter/material.dart';
import 'package:kossumba_app/config/config.dart';

class PropertyFilter {
  final String? search;
  final String? status;
  final double? priceMax;
  final List<String>? facilities;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? category;

  const PropertyFilter({
    this.search,
    this.status,
    this.priceMax,
    this.facilities,
    this.latitude,
    this.longitude,
    this.radius,
    this.category,
  });
}

String getFullImageUrl(String url) {
  if (url.startsWith('/assets')) return '$apiBaseUrl$url';
  return '$apiBaseUrl/storage/$url';
}



  // Widget _buildRoomTypeImagePreviews(
  //     int rtIndex, Map<String, dynamic> roomType) {
  //   final existingImages = (roomType['images'] as List? ?? [])
  //       .cast<Map<String, dynamic>>()
  //       .map((e) => RoomTypeImage.fromJson(e))
  //       .toList();
  //   final newImages = (roomType['image_files'] as List? ?? []).cast<File>();
  //   if (existingImages.isEmpty && newImages.isEmpty) {
  //     return const Text('Belum ada foto untuk tipe kamar ini.',
  //         style: TextStyle(fontStyle: FontStyle.italic));
  //   }
  //   return Wrap(
  //     spacing: 8.0,
  //     runSpacing: 8.0,
  //     children: [
  //       ...existingImages.asMap().entries.map((entry) {
  //         int idx = entry.key;
  //         RoomTypeImage img = entry.value;
  //         return Stack(
  //           children: [
  //             Column(
  //               children: [
  //                 Image.network('$apiBaseUrl/storage/${img.imageUrl}',
  //                     width: 100, height: 100, fit: BoxFit.cover),
  //                 Text(img.type.replaceAll('_', ' ').toTitleCase()),
  //               ],
  //             ),
  //             Positioned(
  //               right: 0,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     roomType['images_to_delete'] ??= <int>[];
  //                     if (!roomType['images_to_delete'].contains(img.id)) {
  //                       roomType['images_to_delete'].add(img.id);
  //                     }

  //                     // Hapus gambar dari list asli berdasarkan ID, bukan index
  //                     (roomType['images'] as List)
  //                         .removeWhere((e) => (e is Map && e['id'] == img.id));

  //                     print(
  //                         "Images to delete for roomType ${roomType['name']}: ${roomType['images_to_delete']}");
  //                   });
  //                 },
  //                 child: const Icon(Icons.remove_circle, color: Colors.red),
  //               ),
  //             ),
  //           ],
  //         );
  //       }).toList(),
  //       ...newImages.asMap().entries.map((entry) {
  //         int idx = entry.key;
  //         File imgFile = entry.value;
  //         return Stack(
  //           children: [
  //             Column(
  //               children: [
  //                 Image.file(imgFile,
  //                     width: 100, height: 100, fit: BoxFit.cover),
  //                 Text(((roomType['image_types'] ?? <String>[])
  //                             .asMap()
  //                             .containsKey(idx)
  //                         ? (roomType['image_types'] as List<String>)[idx]
  //                         : 'unknown')
  //                     .replaceAll('_', ' ')
  //                     .toTitleCase()),
  //               ],
  //             ),
  //             Positioned(
  //               right: 0,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     (roomType['image_files'] as List<File>).removeAt(idx);
  //                     (roomType['image_types'] as List<String>).removeAt(idx);
  //                   });
  //                 },
  //                 child: const Icon(Icons.remove_circle, color: Colors.red),
  //               ),
  //             ),
  //           ],
  //         );
  //       }).toList(),
  //     ],
  //   );
  // }
