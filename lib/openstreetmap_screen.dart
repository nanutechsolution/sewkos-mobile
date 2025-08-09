// lib/openstreetmap_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/kos_service.dart';

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({super.key});

  @override
  State<OpenStreetMapScreen> createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  List<Kos> _kosList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKosMarkers();
  }

  void _fetchKosMarkers() async {
    try {
      List<Kos> kosList = await KosService.getKosList(status: 'kosong');
      setState(() {
        _kosList = kosList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data kos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Kos Sumba (OSM)'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: LatLng(-9.65, 119.39), // Sumba
                zoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kossumba_app',
                ),
                MarkerLayer(
                  markers: _kosList
                      .where((kos) =>
                          kos.latitude != null && kos.longitude != null)
                      .map((kos) => Marker(
                            point: LatLng(kos.latitude!, kos.longitude!),
                            builder: (context) => const Icon(Icons.location_on,
                                color: Colors.red),
                          ))
                      .toList(),
                ),
              ],
            ),
    );
  }
}
