import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/kos.dart';

class KosService {
  static const String _baseUrl = 'http://192.168.93.106:8000/api/kos';
  // static const String _ownerUrl = 'http://192.168.93.106:8000/api/owner';
  static const String _apiUrl = 'http://192.168.93.106:8000/api';

  static Future<List<Kos>> getKosList({
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
    String? location,
    double? priceMax,
    List<String>? facilities,
    String? status,
  }) async {
    final Map<String, String> params = {};
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (latitude != null && longitude != null && radius != null) {
      params['latitude'] = latitude.toString();
      params['longitude'] = longitude.toString();
      params['radius'] = radius.toString();
    }
    if (location != null && location.isNotEmpty) {
      params['location'] = location;
    }
    if (priceMax != null) {
      params['price_max'] = priceMax.toString();
    }
    if (facilities != null && facilities.isNotEmpty) {
      params['facilities'] = facilities.join(',');
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    final uri = Uri.parse('$_apiUrl/kos').replace(queryParameters: params);
    // Uri uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body)['data'];
      return body.map((dynamic item) => Kos.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data kos');
    }
  }

  static Future<Kos> getKosDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return Kos.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat detail kos');
    }
  }

  static Future<void> postReview(
      int kosId, String authorName, String comment, int rating) async {
    final response = await http.post(
      Uri.parse('http://192.168.93.106:8000/api/kos/$kosId/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: json.encode({
        'author_name': authorName,
        'comment': comment,
        'rating': rating,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
          'Gagal mengirim ulasan: ${response.statusCode} ${response.body}');
    }
  }
}
