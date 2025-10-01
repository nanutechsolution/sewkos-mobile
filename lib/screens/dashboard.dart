import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kossumba_app/screens/add_property_screen.dart';
import 'package:kossumba_app/screens/owner/owner_dashboard_screen.dart';
import 'package:kossumba_app/screens/owner/owner_profile_screen.dart';

// Asumsi data ini diambil dari database setelah login
final List<Map<String, dynamic>> ownerPropertiesData = [
  {
    'id': 1,
    'nama': "Kos Sumba Indah",
    'alamat': "Waikabubak",
    'total_kamar': 10,
    'ketersediaan': 3,
    'revenue': 2400000,
    'images': ['https://picsum.photos/400/300?random=11'],
  },
  {
    'id': 2,
    'nama': "Kos Pantai Biru",
    'alamat': "Kodi",
    'total_kamar': 5,
    'ketersediaan': 1,
    'revenue': 1200000,
    'images': ['https://picsum.photos/400/300?random=21'],
  },
  {
    'id': 3,
    'nama': "Kos Tradisional",
    'alamat': "Waitabula",
    'total_kamar': 8,
    'ketersediaan': 5,
    'revenue': 4500000,
    'images': ['https://picsum.photos/400/300?random=41'],
  },
];

class OwnerDashboardScreens extends StatefulWidget {
  const OwnerDashboardScreens({super.key});

  @override
  State<OwnerDashboardScreens> createState() => _OwnerDashboardScreensState();
}

class _OwnerDashboardScreensState extends State<OwnerDashboardScreens> {
  int _selectedIndex = 0;

  final List<Widget> _ownerScreens = [
    const OwnerDashboardContent(),
    const OwnerDashboardScreen(),
    const Center(child: Text('Halaman Pesanan')),
    const OwnerProfileScreen()
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Dashboard Pemilik',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: _ownerScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_rounded),
            label: 'Properti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

// Konten utama Dashboard
class OwnerDashboardContent extends StatelessWidget {
  const OwnerDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    String formatCurrency(int amount) {
      final formatter = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      return formatter.format(amount);
    }

    final totalProperties = ownerPropertiesData.length;
    final totalVacantRooms = ownerPropertiesData
        .map((p) => p['ketersediaan'] as int)
        .reduce((a, b) => a + b);
    final totalRevenue = ownerPropertiesData
        .map((p) => p['revenue'] as int)
        .reduce((a, b) => a + b);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, Pemilik Kos!',
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 24),
          _buildStatsGrid(
            context,
            totalProperties: totalProperties,
            totalVacantRooms: totalVacantRooms,
            totalRevenue: totalRevenue,
          ),
          const SizedBox(height: 24),
          Text(
            'Pesanan Terbaru',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 16),
          // Daftar pesanan terbaru (dummy)
          _buildRecentBookingCard(context),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context,
      {required int totalProperties,
      required int totalVacantRooms,
      required int totalRevenue}) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          'Total Properti',
          totalProperties.toString(),
          Icons.apartment_rounded,
          Colors.blue.shade600,
        ),
        _buildStatCard(
          context,
          'Kamar Kosong',
          totalVacantRooms.toString(),
          Icons.meeting_room_rounded,
          Colors.green.shade600,
        ),
        _buildStatCard(
          context,
          'Total Pendapatan',
          NumberFormat.currency(
                  locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
              .format(totalRevenue),
          Icons.account_balance_wallet_rounded,
          Colors.purple.shade600,
        ),
        _buildStatCard(
          context,
          'Ulasan Baru',
          '3',
          Icons.rate_review_rounded,
          Colors.orange.shade600,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookingCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: NetworkImage('https://placehold.co/100x100/png'),
        ),
        title: Text('Pesanan dari John Doe',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        subtitle: Text('Kos Sumba Indah - Tipe A',
            style: GoogleFonts.poppins(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menuju detail pesanan...')),
          );
        },
      ),
    );
  }
}

// Halaman Properti
class OwnerPropertiesScreen extends StatelessWidget {
  const OwnerPropertiesScreen({super.key});

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Properti',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const AddPropertyScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text('Tambah Kos', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...ownerPropertiesData
              .map((property) => _buildPropertyCard(context, property))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(
      BuildContext context, Map<String, dynamic> property) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Menuju detail properti ${property['nama']}...')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  property['images'][0],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['nama'],
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kamar Tersedia: ${property['ketersediaan']}',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Kamar: ${property['total_kamar']}',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mengedit ${property['nama']}...')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
