import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kossumba_app/services/api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data'; // Key untuk menyimpan data user

  // Metode untuk login pemilik
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await ApiService.ownerLogin(email, password);
    final token = response['token'];
    final userData = response['user']; // Ambil data user dari respons

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(
        _userKey, jsonEncode(userData)); // Simpan data user sebagai JSON string

    return response;
  }

  // Metode untuk mendaftar pemilik baru
  static Future<Map<String, dynamic>> register(String name, String email,
      String password, String passwordConfirmation) async {
    final response = await ApiService.ownerRegister(
        name, email, password, passwordConfirmation);
    final token = response['token'];
    final userData = response['user']; // Ambil data user dari respons

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token); // Simpan token setelah registrasi
    await prefs.setString(
        _userKey, jsonEncode(userData)); // Simpan data user sebagai JSON string

    return response;
  }

  // Metode untuk mengambil token dari local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Metode untuk mengambil data user dari local storage
  static Future<UserModel?> getUserFromStorage() async {
    // PERBAIKAN: Tambahkan metode ini
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return UserModel.fromJson(jsonDecode(userDataString));
    }
    return null;
  }

  // Metode untuk logout (menghapus token dan data user dari local storage)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Metode untuk mengambil profil pengguna (membutuhkan autentikasi)
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    return ApiService.getUserProfile();
  }

  // Metode untuk memperbarui profil pengguna (membutuhkan autentikasi)
  static Future<void> updateUserProfile({
    required String name,
    required String email,
    String? password,
    String? passwordConfirmation,
  }) async {
    await ApiService.updateUserProfile(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
