import 'package:flutter/material.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/screens/property_detail_screen.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final double width;
  final double height;

  const PropertyCard({
    Key? key,
    required this.property,
    this.width = 200,
    this.height = 220,
  }) : super(key: key);

  String getPriceDisplay() {
    if (property.roomTypes.isEmpty) return 'N/A';
    final allPrices =
        property.roomTypes.expand((rt) => rt.prices).where((p) => p.price > 0);
    if (allPrices.isEmpty) return 'N/A';

    final monthly = allPrices.firstWhere((p) => p.periodType == 'monthly',
        orElse: () => allPrices.first);

    if (monthly.price > 0) {
      return 'Rp ${monthly.price.toStringAsFixed(0)} / bulan';
    }

    final daily = allPrices.firstWhere((p) => p.periodType == 'daily',
        orElse: () => allPrices.first);

    return daily.price > 0
        ? 'Rp ${daily.price.toStringAsFixed(0)} / hari'
        : 'N/A';
  }

  String getFirstImageUrl() {
    if (property.images.isNotEmpty) {
      final url = property.images[0].imageUrl;
      return url.startsWith('/assets')
          ? "$apiBaseUrl/$url"
          : "$apiBaseUrl/storage/$url";
    }
    return "$apiBaseUrl/assets/default_property.png";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: property.id)),
      ),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
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
                height: height * 0.55,
                width: double.infinity,
                child: Image.network(
                  getFirstImageUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                      'assets/default_property.png',
                      fit: BoxFit.cover),
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
                  const SizedBox(height: 4),
                  Text(getPriceDisplay(),
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
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
                            style: const TextStyle(fontSize: 11)),
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
}
