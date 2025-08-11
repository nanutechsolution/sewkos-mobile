import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kossumba_app/models/user.dart';
import 'package:kossumba_app/services/auth.service.dart';

// Definisikan state autentikasi
class AuthState {
  final String? token;
  final UserModel? user; // Data user yang login

  AuthState({this.token, this.user});
}

// Definisikan Notifier yang akan mengelola AuthState
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()); // State awal

  // Metode untuk memuat status autentikasi dari storage
  Future<void> loadAuthStatus() async {
    final token = await AuthService.getToken();
    final user = await AuthService.getUserFromStorage();
    state = AuthState(token: token, user: user);
  }

  // Metode untuk memperbarui state setelah login
  void setLoggedIn(String token, UserModel user) {
    state = AuthState(token: token, user: user);
  }

  // Metode untuk memperbarui state setelah logout
  void setLoggedOut() {
    state = AuthState();
  }
}

// Provider yang akan menyediakan AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
