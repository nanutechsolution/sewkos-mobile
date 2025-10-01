import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Impor geolocator

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialPosition = LatLng(-9.6669, 120.2520);
  LatLng _selectedPosition = LatLng(-9.6669, 120.2520);
  double _radius = 5.0;

  @override
  void initState() {
    super.initState();
    _selectedPosition = _initialPosition;
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Izin ditolak
          _showSnackBar('Izin lokasi ditolak.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Izin ditolak permanen
        _showSnackBar(
            'Izin lokasi ditolak permanen. Silakan ubah di pengaturan.');
        return;
      }

      _showSnackBar('Mencari lokasi Anda...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedPosition, 15); // Geser peta ke lokasi baru
      });
      _showSnackBar('Lokasi Anda ditemukan.');
    } catch (e) {
      _showSnackBar('Gagal mendapatkan lokasi: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Pilih Lokasi di Peta',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Gunakan MapController
            options: MapOptions(
              center: _initialPosition,
              zoom: 12.0,
              onTap: (tapPosition, latLng) {
                setState(() {
                  _selectedPosition = latLng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.kossumba_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _selectedPosition,
                    radius: _radius * 1000,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jangkauan: ${_radius.toStringAsFixed(0)} km',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _radius,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '${_radius.toStringAsFixed(0)} km',
                    onChanged: (double value) {
                      setState(() {
                        _radius = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'latitude': _selectedPosition.latitude,
                          'longitude': _selectedPosition.longitude,
                          'radius': _radius,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Terapkan Lokasi',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.my_location_rounded),
      ),
    );
  }
}
