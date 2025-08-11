import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/models/property.dart';

class PropertyService {
  static Future<List<Property>> getPropertiesList({
    String? search,
    String? status,
    double? priceMax,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    double? radius,
    String? category,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priceMax != null) queryParams['price_max'] = priceMax.toString();
    if (facilities != null && facilities.isNotEmpty)
      queryParams['facilities'] = facilities.join(',');
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;

    final uri = Uri.parse('$apiBaseUrl/properties')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception(
          'Gagal memuat daftar properti. Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Property> getPropertyDetail(int propertyId) async {
    final response = await http
        .get(Uri.parse('$apiBaseUrl/properties/$propertyId'), headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return Property.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Gagal memuat detail properti. Status: ${response.statusCode} - ${response.body}');
    }
  }
}
