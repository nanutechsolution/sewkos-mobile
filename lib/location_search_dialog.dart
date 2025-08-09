import 'package:flutter/material.dart';
import 'package:kossumba_app/location_service.dart';

class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({super.key});

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _radiusController =
      TextEditingController(text: '10');
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  void _searchLocation() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      final results =
          await LocationService.searchLocation(_searchController.text.trim());
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ditemukan lokasi sesuai pencarian.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Gagal mencari lokasi.')),
      );
    }
  }

  double get radiusValue {
    final val = double.tryParse(_radiusController.text);
    return (val != null && val > 0) ? val : 10.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cari Lokasi'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari kampus, sekolah, dll.',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
              onSubmitted: (_) => _searchLocation(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _radiusController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Radius (km)',
                helperText: 'Masukkan radius pencarian, default 10 km',
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_searchResults.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Masukkan kata kunci dan tekan cari',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      title: Text(result['name'] ?? 'Nama tidak tersedia'),
                      subtitle: Text(result['address'] ?? ''),
                      onTap: () {
                        Navigator.of(context).pop({
                          'name': result['name'] ?? '',
                          'latitude': result['latitude'],
                          'longitude': result['longitude'],
                          'radius': radiusValue,
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
