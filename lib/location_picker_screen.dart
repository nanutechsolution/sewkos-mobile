import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  String _address = '';
  bool _isPopping = false;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePositionAndSetMap();
  }

  Future<void> _determinePositionAndSetMap() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _address = 'GPS tidak aktif, gunakan peta untuk memilih lokasi';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _address = 'Izin lokasi ditolak, gunakan peta untuk memilih lokasi';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _address = 'Izin lokasi ditolak permanen, buka pengaturan';
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    final currentLatLng = LatLng(position.latitude, position.longitude);

    final addr = await _getAddressFromLatLng(currentLatLng);

    setState(() {
      _pickedLocation = currentLatLng;
      _address = addr ?? 'Alamat tidak ditemukan';
    });

    _mapController.move(currentLatLng, 15);
  }

  Future<String?> _getAddressFromLatLng(LatLng point) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'NanuApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'] as String?;
        return displayName;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _goToCurrentLocation() async {
    setState(() {
      _address = 'Mencari lokasi GPS...';
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);
      final addr = await _getAddressFromLatLng(currentLatLng);

      setState(() {
        _pickedLocation = currentLatLng;
        _address = addr ?? 'Alamat tidak ditemukan';
      });

      _mapController.move(currentLatLng, 15);
    } catch (e) {
      setState(() {
        _address = 'Gagal mengambil lokasi GPS';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Kos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (_pickedLocation != null && !_isPopping)
                ? () async {
                    setState(() {
                      _isPopping = true;
                    });

                    final address =
                        await _getAddressFromLatLng(_pickedLocation!);

                    Navigator.of(context).pop({
                      'latitude': _pickedLocation!.latitude,
                      'longitude': _pickedLocation!.longitude,
                      'address': address ?? _address,
                    });
                  }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _pickedLocation ?? LatLng(-9.65, 119.39),
                zoom: 15,
                onTap: (tapPosition, point) async {
                  setState(() {
                    _pickedLocation = point;
                    _address = 'Mencari alamat...';
                  });

                  final address = await _getAddressFromLatLng(point);

                  setState(() {
                    _address = address ?? 'Alamat tidak ditemukan';
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kossumba_app',
                ),
                if (_pickedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pickedLocation!,
                        width: 80,
                        height: 80,
                        builder: (context) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Text(
              _address.isEmpty ? 'Tap di peta untuk memilih lokasi' : _address,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Lokasi Saya',
        child: const Icon(Icons.my_location),
        onPressed: _goToCurrentLocation,
      ),
    );
  }
}
