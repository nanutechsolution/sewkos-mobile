import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageRoomsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;
  final String roomTypeName;

  const ManageRoomsScreen({
    super.key,
    required this.rooms,
    required this.roomTypeName,
  });

  @override
  State<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

enum RoomStatus { kosong, digunakan, renovasi }

class _ManageRoomsScreenState extends State<ManageRoomsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _filteredRooms = widget.rooms;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    for (var room in widget.rooms) {
      (room['name'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRooms = widget.rooms.where((room) {
        final roomName =
            (room['name'] as TextEditingController).text.toLowerCase();
        return roomName.contains(query);
      }).toList();
    });
  }

  String _getStringFromStatus(RoomStatus status) {
    switch (status) {
      case RoomStatus.kosong:
        return 'Kosong';
      case RoomStatus.digunakan:
        return 'Digunakan';
      case RoomStatus.renovasi:
        return 'Renovasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Kelola ${widget.roomTypeName}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context, widget.rooms);
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama kamar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Expanded(
            child: _filteredRooms.isEmpty
                ? Center(
                    child: Text('Kamar tidak ditemukan.',
                        style: GoogleFonts.poppins()))
                : ListView.builder(
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      return _buildRoomManagementCard(room, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomManagementCard(Map<String, dynamic> room, int roomNumber) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: room['name'] as TextEditingController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kamar',
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 130, // Lebar fixed untuk DropdownButton
              child: DropdownButtonFormField<String>(
                value: room['status'] as String,
                items: ['Kosong', 'Digunakan', 'Renovasi'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child:
                        Text(value, style: GoogleFonts.poppins(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      room['status'] = newValue;
                    });
                  }
                },
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
