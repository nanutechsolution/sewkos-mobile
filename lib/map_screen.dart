// // lib/map_screen.dart

// import 'package:flutter/material.dart';
// import 'package:kossumba_app/kos.dart';
// import 'package:kossumba_app/kos_service.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   final LatLng _initialPosition = const LatLng(-9.65, 119.39);
//   Set<Marker> _markers = {};
//   LatLng? _userCurrentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndLoad();
//   }

//   void _checkPermissionsAndLoad() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Layanan lokasi tidak diaktifkan.
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Izin ditolak.
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Izin ditolak permanen.
//       return;
//     }

//     _getCurrentLocation();
//     _loadKosMarkers();
//   }

//   void _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     _userCurrentPosition = LatLng(position.latitude, position.longitude);

//     if (mapController != null) {
//       mapController.animateCamera(
//         CameraUpdate.newLatLng(_userCurrentPosition!),
//       );
//     }

//     setState(() {}); // update UI
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   void _loadKosMarkers() async {
//     try {
//       List<Kos> kosList = await KosService.getKosList();
//       setState(() {
//         _markers = kosList
//             .where((kos) => kos.latitude != null && kos.longitude != null)
//             .map((kos) => Marker(
//                   markerId: MarkerId(kos.id.toString()),
//                   position: LatLng(kos.latitude!, kos.longitude!),
//                   infoWindow: InfoWindow(
//                     title: kos.name,
//                     snippet: kos.location,
//                   ),
//                 ))
//             .toSet();
//       });
//     } catch (e) {
//       print('Failed to load kos markers: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Peta Kos Sumba'),
//         backgroundColor: Colors.blue,
//       ),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 10.0,
//         ),
//         markers: _markers,
//         myLocationEnabled: true, // Tambahkan ini
//         myLocationButtonEnabled: true, // Tambahkan ini
//       ),
//     );
//   }
// }
