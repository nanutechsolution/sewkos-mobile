import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kossumba_app/screens/map_search_screen.dart'; // Import halaman baru

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(0, 5000000);
  final List<String> _selectedFacilities = [];
  final List<String> _facilities = [
    'WiFi',
    'AC',
    'Kamar Mandi Dalam',
    'Parkir Motor',
    'Dapur',
    'Laundry'
  ];

  // Tambahkan state untuk lokasi peta
  Map<String, dynamic>? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Filter Kos',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _priceRange = const RangeValues(0, 5000000);
                _selectedFacilities.clear();
                _selectedLocation = null; // Reset lokasi
              });
            },
            child: Text('Reset',
                style: GoogleFonts.poppins(color: Colors.red.shade400)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Jangkauan Harga
            _buildSectionTitle('Harga per Bulan'),
            const SizedBox(height: 12),
            _buildPriceRangeDisplay(),
            const SizedBox(height: 12),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000000,
              divisions: 20,
              activeColor: Colors.blue.shade600,
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 24),

            // Filter Fasilitas
            _buildSectionTitle('Fasilitas Populer'),
            _buildFacilitiesChips(),
            const Spacer(),

            // Tombol Pencarian via Google Maps
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded),
                label: Text(
                    _selectedLocation != null
                        ? 'Lokasi dipilih (${_selectedLocation!['radius'].toStringAsFixed(0)} km)'
                        : 'Cari di Peta',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MapSearchScreen()),
                  );
                  if (result != null) {
                    setState(() {
                      _selectedLocation = result as Map<String, dynamic>;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Terapkan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Kirim filter kembali ke halaman sebelumnya
                  Navigator.of(context).pop({
                    'priceRange': _priceRange,
                    'facilities': _selectedFacilities,
                    'location': _selectedLocation,
                  });
                },
                child: Text('Terapkan Filter',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget lainnya tetap sama...
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPriceRangeDisplay() {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rp ${formatter.format(_priceRange.start)}',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Rp ${formatter.format(_priceRange.end)}',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFacilitiesChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _facilities.map((fac) {
        final isSelected = _selectedFacilities.contains(fac);
        return FilterChip(
          label: Text(
            fac,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.blue.shade800,
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedFacilities.add(fac);
              } else {
                _selectedFacilities.remove(fac);
              }
            });
          },
          selectedColor: Colors.blue.shade600,
          backgroundColor: Colors.blue.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color:
                    isSelected ? Colors.blue.shade600 : Colors.blue.shade200),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
