import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  String _address = "Memuat lokasi...";
  bool _loadingAddress = false;
  bool _loadingGPS = true;

  final LatLng _defaultJakarta = LatLng(-6.200000, 106.816666);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Ambil lokasi GPS perangkat
  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingGPS = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Layanan lokasi dimatikan");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Izin lokasi ditolak");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Izin lokasi ditolak permanen");
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _pickedLocation = LatLng(pos.latitude, pos.longitude);
      });
      await _getAddressFromLatLng(_pickedLocation!, saveResult: false);
    } catch (e) {
      print("GPS Error: $e");
      setState(() {
        _pickedLocation = _defaultJakarta; // fallback
        _address = "Gunakan titik default (Jakarta)";
      });
    } finally {
      setState(() {
        _loadingGPS = false;
      });
    }
  }

  /// Ambil alamat dari koordinat
  Future<void> _getAddressFromLatLng(LatLng position,
      {bool saveResult = true}) async {
    setState(() {
      _loadingAddress = true;
    });

    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1");

    try {
      final response = await http.get(url, headers: {
        "User-Agent": "FlutterApp" // wajib biar gak diblokir OSM
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressData = data["address"] ?? {};
        final street = addressData["road"] ?? "";
        final city = addressData["city"] ??
            addressData["town"] ??
            addressData["village"] ??
            "";
        final province = addressData["state"] ?? "";
        final postalCode = addressData["postcode"] ?? "";

        setState(() {
          _address = data["display_name"] ?? "Alamat tidak ditemukan";
        });

        if (saveResult) {
          Navigator.pop(context, {
            "address_street": street,
            "address_city": city,
            "address_province": province,
            "address_zip_code": postalCode,
            "latitude": position.latitude,
            "longitude": position.longitude,
            "full_address": _address
          });
        }
      } else {
        throw Exception("Gagal mengambil alamat");
      }
    } catch (e) {
      debugPrint("Address Error: $e");
      setState(() {
        _address = "Gagal mengambil alamat";
      });
    } finally {
      setState(() {
        _loadingAddress = false;
      });
    }
  }

  /// Pilih lokasi manual dari peta
  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: "Gunakan GPS",
            onPressed: _getCurrentLocation,
          )
        ],
      ),
      body: _loadingGPS
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: _pickedLocation ?? _defaultJakarta,
                    zoom: 15.0,
                    onTap: (tapPosition, point) {
                      _selectLocation(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.app",
                    ),
                    if (_pickedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: _pickedLocation!,
                            builder: (ctx) => const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          )
                        ],
                      ),
                  ],
                ),
                if (_loadingAddress)
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    minHeight: 4,
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          _address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Gunakan Lokasi Ini"),
                        onPressed: () {
                          if (_pickedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Lokasi belum dipilih")),
                            );
                            return;
                          }
                          _getAddressFromLatLng(_pickedLocation!);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
