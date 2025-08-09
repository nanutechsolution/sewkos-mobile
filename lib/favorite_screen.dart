import 'package:flutter/material.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/kos_service.dart';
import 'package:kossumba_app/favorite_service.dart';
import 'package:kossumba_app/kos_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Future<List<Kos>> _favoriteKosFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _fetchFavoriteKos();
  }

  void _fetchFavoriteKos() async {
    List<String> favoriteIds = await FavoriteService.getFavoriteKosIds();
    List<Kos> favoriteKosList = [];
    for (String id in favoriteIds) {
      try {
        final kos = await KosService.getKosDetail(int.parse(id));
        favoriteKosList.add(kos);
      } catch (e) {
        print('Failed to load favorite kos with ID: $id');
      }
    }
    setState(() {
      _favoriteKosFuture = Future.value(favoriteKosList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kos Favorit'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Kos>>(
        future: _favoriteKosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final kosList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: kosList.length,
              itemBuilder: (context, index) {
                final kos = kosList[index];
                return _buildKosCard(kos, context);
              },
            );
          } else {
            return const Center(
                child: Text('Anda belum menambahkan kos favorit.'));
          }
        },
      ),
    );
  }

  Widget _buildKosCard(Kos kos, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => KosDetailScreen(kosId: kos.id)),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    kos.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image,
                          size: 80, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kos.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(kos.location,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      kos.price,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
