import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.93.106:8000/api/owner/login';
  static const String _tokenKey = 'auth_token';
  static const String _authUrl = 'http://192.168.93.106:8000/api';

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return token;
    } else {
      throw Exception('Gagal login. Cek kredensial Anda.');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    final response = await http.get(
      Uri.parse('$_authUrl/user/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception(
          'Gagal mengambil data profil. Status: ${response.statusCode}');
    }
  }

  static Future<void> updateUserProfile({
    required String name,
    required String email,
    String? password,
    String? passwordConfirmation,
  }) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Pengguna tidak terautentikasi.');
    }

    Map<String, dynamic> body = {
      'name': name,
      'email': email,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      body['password_confirmation'] = passwordConfirmation;
    }

    final response = await http.put(
      Uri.parse('$_authUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message']);
    }
  }
}
