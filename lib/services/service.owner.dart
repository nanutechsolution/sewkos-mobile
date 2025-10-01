import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:kossumba_app/services/service.api.dart';
import 'package:mime/mime.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerServices {
  static const _endpoint = 'api/owner/properties';
  static Future<http.Response> _sendRequest(String method, String url,
      {dynamic data, List<File>? files, bool isMultipart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uri = Uri.parse(url);
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      if (isMultipart) {
        final request = http.MultipartRequest(method, uri);
        request.headers.addAll(headers);
        if (data != null) {
          data.forEach((key, value) {
            if (value is String) {
              request.fields[key] = value;
            } else if (value is int) {
              request.fields[key] = value.toString();
            } else if (value is List) {
              for (var i = 0; i < value.length; i++) {
                request.fields['$key[$i]'] = value[i].toString();
              }
            }
          });
        }
        if (files != null) {
          for (var file in files) {
            final mimeTypeData =
                lookupMimeType(file.path, headerBytes: [0xFF, 0xD8])
                    ?.split('/');
            final multipartFile = await http.MultipartFile.fromPath(
              'files[]', // Ganti dengan nama field file yang benar
              file.path,
              contentType: (mimeTypeData != null)
                  ? MediaType(mimeTypeData[0], mimeTypeData[1])
                  : null,
            );
            request.files.add(multipartFile);
          }
        }
        final streamedResponse = await request.send();
        return http.Response.fromStream(streamedResponse);
      } else {
        final body = data != null ? json.encode(data) : null;
        final response = await http.post(uri, headers: headers, body: body);
        return response;
      }
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Future<List<Property>> fetchOwnerPropertiesList() async {
    final response = await ApiServices.get(
      _endpoint,
      authRequired: true,
    );

    // Periksa jika respons memiliki kunci 'data'
    if (response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => Property.fromJson(json))
          .toList();
    } else {
      throw Exception('Format respons API tidak valid');
    }
  }

  static Future<Property> uploadProperty(
      {required Map<String, dynamic> payload}) async {
    final response = await ApiServices.post(
      _endpoint,
      payload,
      authRequired: true,
      isMultipart: true,
    );
    return Property.fromJson(response['data']);
  }

  static Future<Property> updateProperty({
    required int propertyId,
    required Map<String, dynamic> payload,
  }) async {
    // API endpoint untuk update properti (PUT method)
    final url = '$_endpoint/$propertyId';

    // Asumsi API service Anda sudah menangani pengiriman data multipart/form-data untuk file
    // dan JSON untuk data lainnya. Anda mungkin perlu menyesuaikan ini.
    final response = await ApiServices.put(
      url,
      payload,
      authRequired: true,
      isMultipart: true, // Asumsikan Anda mengizinkan file di payload update
    );

    return Property.fromJson(response['data']);
  }

  static Future<void> deleteProperty(int propertyId) async {
    await ApiServices.delete('$_endpoint/$propertyId', authRequired: true);
  }
}
