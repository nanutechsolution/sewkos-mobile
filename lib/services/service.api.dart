// services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/services/auth.service.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

// URL dasar untuk API Anda
const String _apiBaseUrl =
    'http://192.168.137.1:8000/'; // Gunakan 10.0.2.2 untuk emulator Android

class ApiServices {
  /// Helper method untuk mengirim semua request HTTP.
  static Future<dynamic> _sendRequest({
    required String method,
    required String endpoint,
    dynamic data,
    bool authRequired = false,
    bool isMultipart = false,
  }) async {
    String? token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Pengguna tidak terautentikasi. Token tidak ditemukan.');
    }
    final uri = Uri.parse('$_apiBaseUrl$endpoint');
    final headers = {
      'Accept': 'application/json',
      if (authRequired && token != null) 'Authorization': 'Bearer $token',
      if (!isMultipart) 'Content-Type': 'application/json',
    };

    http.Response response;

    try {
      if (isMultipart) {
        final request = http.MultipartRequest(method, uri);
        request.headers.addAll(headers);

        // Menambahkan data JSON sebagai fields
        if (data != null) {
          data.forEach((key, value) {
            if (value is String) {
              request.fields[key] = value;
            } else if (value is int) {
              request.fields[key] = value.toString();
            } else if (value is List) {
              request.fields[key] = json.encode(value);
            } else if (value is Map) {
              request.fields[key] = json.encode(value);
            }
          });
        }

        // Menambahkan file jika ada
        if (data != null && data.containsKey('files')) {
          for (var file in data['files']) {
            if (file is File) {
              final mimeTypeData = lookupMimeType(file.path)?.split('/');
              final multipartFile = await http.MultipartFile.fromPath(
                'files[]',
                file.path,
                contentType: (mimeTypeData != null)
                    ? MediaType(mimeTypeData[0], mimeTypeData[1])
                    : null,
              );
              request.files.add(multipartFile);
            }
          }
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final body = data != null ? json.encode(data) : null;
        switch (method) {
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'POST':
            response = await http.post(uri, headers: headers, body: body);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: body);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
          default:
            throw Exception('Metode HTTP tidak didukung.');
        }
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server.');
    } catch (e) {
      throw Exception('Gagal mengirim permintaan: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return {'message': 'Berhasil, tanpa konten.'};
    } else {
      dynamic errorData;
      if (response.body.isNotEmpty) {
        errorData = json.decode(response.body);
      }
      throw Exception(errorData['message'] ??
          'Permintaan gagal dengan status ${response.statusCode}');
    }
  }

  // Metode publik untuk setiap verb HTTP
  static Future<dynamic> get(String endpoint, {bool authRequired = false}) {
    return _sendRequest(
      method: 'GET',
      endpoint: endpoint,
      authRequired: authRequired,
    );
  }

  static Future<dynamic> post(String endpoint, dynamic data,
      {bool authRequired = false, bool isMultipart = false}) {
    return _sendRequest(
      method: 'POST',
      endpoint: endpoint,
      data: data,
      authRequired: authRequired,
      isMultipart: isMultipart,
    );
  }

  static Future<dynamic> put(String endpoint, dynamic data,
      {bool authRequired = false, bool isMultipart = false}) {
    return _sendRequest(
      method: 'PUT',
      endpoint: endpoint,
      data: data,
      authRequired: authRequired,
      isMultipart: isMultipart,
    );
  }

  static Future<dynamic> delete(String endpoint, {bool authRequired = false}) {
    return _sendRequest(
      method: 'DELETE',
      endpoint: endpoint,
      authRequired: authRequired,
    );
  }
}
