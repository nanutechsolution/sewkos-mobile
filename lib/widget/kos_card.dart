import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kossumba_app/config.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/kos_detail_screen.dart';

class KosCard extends StatelessWidget {
  final Kos kos;
  const KosCard({super.key, required this.kos});

  String _formatRupiah(String price) {
    try {
      double value =
          double.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return NumberFormat.currency(
              locale: 'id', symbol: 'Rp ', decimalDigits: 0)
          .format(value);
    } catch (_) {
      return price;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => KosDetailScreen(kosId: kos.id)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar kos
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
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info kos
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
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kos.location,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatRupiah(kos.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text(
                        'Fasilitas: ${kos.facilities.join(', ')}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
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
}
