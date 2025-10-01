import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kossumba_app/screens/dashboard.dart';
import 'package:kossumba_app/services/auth.service.dart';

class ProfileScreens extends StatelessWidget {
  const ProfileScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profil yang lebih personal
            _buildProfileHeader(context),
            const SizedBox(height: 32),

            // Bagian Aksi Cepat
            _buildSectionTitle('Aksi Cepat'),
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Bagian Menu Lainnya
            _buildSectionTitle('Pengaturan & Bantuan'),
            _buildOtherSettings(context),
            const SizedBox(height: 48),

            // Tombol Logout
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const NetworkImage(
              'https://placehold.co/200x200/png',
            ), // Ganti dengan URL foto profil pengguna
          ),
          const SizedBox(height: 16),
          Text(
            'Halo, Nama Pengguna!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'email.user@example.com',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // Aksi untuk mengedit profil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menuju halaman Edit Profil...')),
              );
            },
            icon: const Icon(Icons.edit, size: 18),
            label: Text(
              'Edit Profil',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              context,
              icon: Icons.history_rounded,
              label: 'Riwayat',
              onTap: () {},
            ),
            _buildQuickActionItem(context,
                icon: Icons.dashboard_customize, label: 'Dashboard', onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const OwnerDashboardScreens()),
                (route) => false,
              );
            }),
            _buildQuickActionItem(
              context,
              icon: Icons.credit_card_rounded,
              label: 'Bayar',
              onTap: () {},
            ),
            _buildQuickActionItem(
              context,
              icon: Icons.help_outline_rounded,
              label: 'Bantuan',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettings(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuItem(context, 'Pengaturan Akun', Icons.settings_rounded),
          _buildMenuItem(
              context, 'Tentang Aplikasi', Icons.info_outline_rounded),
          _buildMenuItem(
              context, 'Kebijakan Privasi', Icons.privacy_tip_rounded),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Menuju halaman $title...')),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          AuthService.logout();
        },
        child: Text(
          'Keluar (Logout)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
