import 'package:flutter/material.dart';
import 'package:kossumba_app/screens/owner/owner_login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: Colors.transparent, elevation: 0, actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog login
            },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
              size: 28,
            ))
      ]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masuk sebagai:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_search),
              label: const Text('Pencari Kos'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const OwnerLoginScreen()),
                );
              },
              icon: const Icon(Icons.business),
              label: const Text('Pemilik Kos'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Atau masuk dengan',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _socialLoginButton(
                  icon: Icons.g_mobiledata,
                  color: Colors.red,
                  label: 'Google',
                  onPressed: () {
                    // TODO: Implement Google Sign-In
                  },
                ),
                _socialLoginButton(
                  icon: Icons.facebook,
                  color: Colors.blue.shade800,
                  label: 'Facebook',
                  onPressed: () {
                    // TODO: Implement Facebook Login
                  },
                ),
                _socialLoginButton(
                  icon: Icons.apple,
                  color: Colors.black,
                  label: 'Apple',
                  onPressed: () {
                    // TODO: Implement Apple Sign-In
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(100, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 24),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
