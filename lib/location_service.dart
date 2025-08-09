import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String baseUrl = 'http://192.168.93.106:8000/api';

  static Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final uri = Uri.parse(
        '$baseUrl/search-location?query=${Uri.encodeComponent(query)}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      if (jsonBody['status'] == 'success' && jsonBody['places'] != null) {
        List places = jsonBody['places'];
        return places.map<Map<String, dynamic>>((place) {
          return {
            'name': place['name'] ?? '',
            'address': place['address'] ?? '',
            'latitude': double.tryParse(place['latitude'].toString()) ?? 0.0,
            'longitude': double.tryParse(place['longitude'].toString()) ?? 0.0,
          };
        }).toList();
      } else {
        throw Exception(jsonBody['message'] ?? 'Gagal mengambil data lokasi');
      }
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  static Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng';

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent':
          'kossumba_app/1.0 (email@example.com)', // wajib biar gak diblok
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] as String?;
    } else {
      return null;
    }
  }
}
