import 'package:flutter/material.dart';
import 'package:kossumba_app/auth_service.dart';
import 'package:kossumba_app/owner_login_screen.dart';
import 'package:kossumba_app/owner_dashboard_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    String? token = await AuthService.getToken();
    if (token != null) {
      // Jika token ada, arahkan ke dashboard pemilik
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
      );
    } else {
      // Jika token tidak ada, arahkan ke halaman login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OwnerLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan loading sementara
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
