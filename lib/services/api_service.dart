import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/models/facility.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/services/auth.service.dart';
import 'package:kossumba_app/config/config.dart';

class ApiService {
  static const String _apiBaseUrl = apiBaseUrl;
  // --- Metode Helper Generik untuk Mengirim Permintaan ---
  static Future<Map<String, dynamic>> _sendRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    bool authRequired = false,
    bool isMultipart = false,
    Map<String, dynamic>? multipartFields,
    List<http.MultipartFile>? multipartFiles,
    String? customMethod,
  }) async {
    Uri uri = Uri.parse('$_apiBaseUrl$endpoint');
    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (authRequired) {
      String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
            'Pengguna tidak terautentikasi. Token tidak ditemukan.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;

    if (isMultipart) {
      var request = http.MultipartRequest(method, uri);
      request.headers.addAll(headers);

      if (multipartFields != null) {
        multipartFields.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
      }
      if (multipartFiles != null) {
        request.files.addAll(multipartFiles);
      }
      if (customMethod != null) {
        request.fields['_method'] = customMethod;
      }

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } else {
      headers['Content-Type'] = 'application/json';
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response =
              await http.post(uri, headers: headers, body: json.encode(data));
          break;
        case 'PUT':
          response =
              await http.put(uri, headers: headers, body: json.encode(data));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Metode HTTP tidak didukung: $method');
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized: Token tidak valid atau sudah kadaluarsa.");
    } else {
      throw Exception(
        'Permintaan gagal: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // --- Metode untuk Properti (Public & Owner) ---

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
    final uri =
        Uri.parse('/api/properties').replace(queryParameters: queryParams);
    final response = await _sendRequest(
        method: 'GET',
        endpoint: uri.path + (uri.query.isEmpty ? '' : '?${uri.query}'));
    return (response['data'] as List)
        .map((json) => Property.fromJson(json))
        .toList();
  }

  // GET /api/properties/{property}
  static Future<Property> getPropertyDetail(int propertyId) async {
    final response = await _sendRequest(
        method: 'GET', endpoint: '/api/properties/$propertyId');
    return Property.fromJson(response);
  }

  // POST /api/properties/{property}/reviews
  static Future<void> postReview(
      int propertyId, String authorName, String comment, int rating) async {
    await _sendRequest(
      method: 'POST',
      endpoint: '/api/properties/$propertyId/reviews',
      data: {
        'author_name': authorName,
        'comment': comment,
        'rating': rating,
      },
    );
  }

  // GET /api/owner/properties (Authenticated)
  static Future<List<Property>> getOwnerPropertiesList() async {
    final response = await _sendRequest(
        method: 'GET', endpoint: '/api/owner/properties', authRequired: true);
    return (response['data'] as List)
        .map((json) => Property.fromJson(json))
        .toList();
  }

  // POST /api/owner/properties (Authenticated, Multipart)
  static Future<Property> uploadProperty({
    required Map<String, dynamic> fields,
    required List<http.MultipartFile> files,
  }) async {
    final response = await _sendRequest(
      method: 'POST',
      endpoint: '/api/owner/properties',
      authRequired: true,
      isMultipart: true,
      multipartFields: fields,
      multipartFiles: files,
    );
    return Property.fromJson(response['data']);
  }

  // PUT /api/owner/properties/{property} (Authenticated, Multipart)
  static Future<Property> updateProperty({
    required int propertyId,
    required Map<String, dynamic> fields,
    required List<http.MultipartFile> files,
  }) async {
    final response = await _sendRequest(
      method: 'POST', // Kirim sebagai POST
      endpoint: '/api/owner/properties/$propertyId',
      authRequired: true,
      isMultipart: true,
      multipartFields: fields,
      multipartFiles: files,
      customMethod: 'PUT', // Override metode ke PUT
    );
    return Property.fromJson(response['data']);
  }

  // DELETE /api/owner/properties/{property} (Authenticated)
  static Future<void> deleteProperty(int propertyId) async {
    await _sendRequest(
      method: 'DELETE',
      endpoint: '/api/owner/properties/$propertyId',
      authRequired: true,
    );
  }

  // --- Metode untuk Autentikasi & Profil ---

  // POST /api/owner/register
  static Future<Map<String, dynamic>> ownerRegister(String name, String email,
      String password, String passwordConfirmation) async {
    final response = await _sendRequest(
      method: 'POST',
      endpoint: '/api/owner/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return response; // Mengembalikan token dan user data
  }

  // POST /api/owner/login
  static Future<Map<String, dynamic>> ownerLogin(
      String email, String password) async {
    final response = await _sendRequest(
      method: 'POST',
      endpoint: '/api/owner/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response; // Mengembalikan token dan user data
  }

  // GET /api/user/profile (Authenticated)
  static Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _sendRequest(
        method: 'GET', endpoint: '/api/user/profile', authRequired: true);
    return response['data'];
  }

  // PUT /api/user/profile (Authenticated)
  static Future<void> updateUserProfile({
    required String name,
    required String email,
    String? password,
    String? passwordConfirmation,
  }) async {
    await _sendRequest(
      method: 'PUT',
      endpoint: '/api/user/profile',
      authRequired: true,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // --- Metode untuk Fasilitas ---

  // GET /api/facilities
  static Future<List<Facility>> getFacilities() async {
    final response =
        await _sendRequest(method: 'GET', endpoint: '/api/facilities');
    return (response['data'] as List)
        .map((json) => Facility.fromJson(json))
        .toList();
  }

  // --- Metode untuk Status Kamar (Jika diperlukan) ---
  // PUT /api/owner/rooms/{roomId}/status
  static Future<void> updateRoomStatus(int roomId, String newStatus) async {
    await _sendRequest(
      method: 'PUT',
      endpoint:
          '/api/owner/rooms/$roomId/status', // Pastikan endpoint ini ada di backend
      authRequired: true,
      data: {'status': newStatus},
    );
  }
}
