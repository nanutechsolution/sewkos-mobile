import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // appBar: AppBar(
      //   title: Text(
      //     'Profil Saya',
      //     style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      //   ),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black87,
      //   elevation: 1,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Pengaturan Akun'),
            _buildAccountMenu(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Bantuan & Informasi'),
            _buildInfoMenu(context),
            const SizedBox(height: 48),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundImage: NetworkImage(
                'https://placehold.co/200x200/png'), // Ganti dengan foto profil
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'pemilik.kos@email.com',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text('Edit Profil',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

  Widget _buildAccountMenu(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuItem(context, 'Ganti Password', Icons.lock_rounded, () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(
              context, 'Kelola Pembayaran', Icons.credit_card_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildInfoMenu(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildMenuItem(
              context, 'Pusat Bantuan', Icons.help_outline_rounded, () {}),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildMenuItem(
              context, 'Tentang Kami', Icons.info_outline_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(title,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda telah logout.')),
          );
          Navigator.of(context).pop(); // Kembali ke halaman utama
        },
        child: Text(
          'Keluar (Logout)',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
