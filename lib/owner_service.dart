import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/auth_service.dart';
import 'dart:convert';
import 'package:kossumba_app/kos.dart';

class OwnerService {
  static const String _baseUrl = 'http://192.168.93.106:8000/api/owner';

  static Future<List<Kos>> fetchOwnerKosList() async {
    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan atau kosong');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> kosJson = data['data'];
      return kosJson.map((json) => Kos.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Token tidak valid atau kedaluwarsa.');
    } else {
      throw Exception(
          'Gagal memuat daftar kos pemilik. Status: ${response.statusCode}');
    }
  }

  static Future<void> uploadKos({
    required String name,
    required String location,
    required String price,
    required String description,
    required String facilities,
    required String status,
    required File image,
    double? latitude,
    double? longitude,
  }) async {
    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan atau kosong');
    }

    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/kos'));

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = name;
    request.fields['location'] = location;
    request.fields['price'] = price;
    request.fields['description'] = description;
    request.fields['facilities'] = facilities;
    request.fields['status'] = status;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    // Debug: print semua fields yang akan dikirim
    print('--- Multipart Request Fields ---');
    request.fields.forEach((key, value) {
      print('$key: $value');
    });
    print('--- Multipart Request Files ---');
    request.files.forEach((file) {
      print('Field: ${file.field}, Filename: ${file.filename}');
    });
    print('-----------------------------');

    final response = await request.send();

    final respStr = await response.stream.bytesToString();
    print('Upload response: $respStr');

    if (response.statusCode != 201) {
      throw Exception('Failed to upload kos, status: ${response.statusCode}');
    }
  }

  static Future<Kos> updateKosStatus(int kosId, String newStatus) async {
    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan atau kosong');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/kos/$kosId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Kos.fromJson(data['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Token tidak valid atau kedaluwarsa.');
    } else {
      throw Exception(
          'Gagal memperbarui status kos. Status: ${response.statusCode}');
    }
  }

  static Future<Kos> updateKos({
    required int kosId,
    required String name,
    required String location,
    required String price,
    required String description,
    required String facilities,
    required String status,
    double? latitude, // tambahkan ini
    double? longitude, // tambahkan ini
    File? imageFile,
  }) async {
    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan atau kosong');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/kos/$kosId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'location': location,
        'price': price,
        'description': description,
        'facilities': facilities,
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Kos.fromJson(data['data']);
    } else {
      throw Exception('Gagal memperbarui kos. Status: ${response.statusCode}');
    }
  }

  static Future<void> deleteKos(int kosId) async {
    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan atau kosong');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/kos/$kosId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus kos. Status: ${response.statusCode}');
    }
  }
}
