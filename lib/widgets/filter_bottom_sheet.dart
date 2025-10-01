import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late List<String> _selectedFacilities;

  final List<String> _facilities = [
    'WiFi',
    'AC',
    'Kamar Mandi Dalam',
    'Parkir Motor',
    'Dapur',
    'TV',
    'Gym'
  ];

  @override
  void initState() {
    super.initState();
    _priceRange =
        widget.initialFilters['priceRange'] ?? const RangeValues(0, 5000000);
    _selectedFacilities = List.from(widget.initialFilters['facilities'] ?? []);
  }

  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 5000000);
      _selectedFacilities.clear();
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'priceRange': _priceRange,
      'facilities': _selectedFacilities,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Pencarian',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text('Reset',
                    style: GoogleFonts.poppins(color: Colors.red.shade400)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter Jangkauan Harga
          Text('Harga per Bulan',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          _buildPriceRangeDisplay(),
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
          Text('Fasilitas Populer',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFacilitiesChips(),

          const Spacer(),

          // Tombol Terapkan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
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
    );
  }

  Widget _buildPriceRangeDisplay() {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rp ${formatter.format(_priceRange.start)}',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Rp ${formatter.format(_priceRange.end)}',
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
