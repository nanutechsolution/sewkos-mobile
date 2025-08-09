import 'package:flutter/material.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/kos_service.dart';
import 'package:kossumba_app/favorite_service.dart';
import 'package:url_launcher/url_launcher.dart';

class KosDetailScreen extends StatefulWidget {
  final int kosId;

  const KosDetailScreen({Key? key, required this.kosId}) : super(key: key);

  @override
  State<KosDetailScreen> createState() => _KosDetailScreenState();
}

class _KosDetailScreenState extends State<KosDetailScreen> {
  late Future<Kos> _kosDetailFuture;
  bool _isFavorite = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _authorNameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchKosDetail();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _authorNameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _fetchKosDetail() {
    setState(() {
      _kosDetailFuture = KosService.getKosDetail(widget.kosId);
    });
  }

  void _checkIfFavorite() async {
    bool isFav = await FavoriteService.isFavorite(widget.kosId);
    setState(() => _isFavorite = isFav);
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await FavoriteService.removeFavoriteKos(widget.kosId);
    } else {
      await FavoriteService.addFavoriteKos(widget.kosId);
    }
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
      ),
    );
  }

  void _submitReview() async {
    if (_formKey.currentState!.validate() && _selectedRating > 0) {
      try {
        await KosService.postReview(
          widget.kosId,
          _authorNameController.text,
          _commentController.text,
          _selectedRating,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil dikirim!')),
        );
        _authorNameController.clear();
        _commentController.clear();
        setState(() => _selectedRating = 0);
        _fetchKosDetail();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
    }
  }

  void _launchNavigation(BuildContext context, double lat, double lng) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        // fallback ke platform default kalau gagal
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }

  String getFullImageUrl(String url) {
    if (url.startsWith('/storage') || url.startsWith('/assets')) {
      return 'http://192.168.93.106:8000$url'; // ini sudah benar
    }
    // kemungkinan kamu gabung baseUrl + url yang sudah ada port
    if (url.startsWith('http://192.168.93.106:8000')) {
      return url; // jangan tambah port lagi
    }
    // fallback replace IP dan port
    return url.replaceAll(
        RegExp(r'http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?'),
        'http://192.168.93.106:8000');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Kos>(
      future: _kosDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: Text('Kos tidak ditemukan')));
        }

        final kos = snapshot.data!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleFavorite,
                    tooltip: _isFavorite ? 'Hapus Favorit' : 'Tambah Favorit',
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        getFullImageUrl(kos.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 250, color: Colors.grey),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black45, Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kos.name,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        Text(kos.location,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600])),
                        const SizedBox(height: 20),
                        const Divider(thickness: 1),
                        const SizedBox(height: 20),
                        const SectionTitle(title: 'Deskripsi'),
                        const SizedBox(height: 10),
                        Text(kos.description,
                            style: const TextStyle(fontSize: 16, height: 1.4)),
                        const SizedBox(height: 25),
                        const Divider(thickness: 1),
                        const SizedBox(height: 20),
                        const SectionTitle(title: 'Fasilitas'),
                        const SizedBox(height: 16),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: kos.facilities
                              .map((f) => FacilityItem(
                                  icon: Icons.check_circle_outline, text: f))
                              .toList(),
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton.icon(
                          onPressed: () => _launchNavigation(
                              context, kos.latitude!, kos.longitude!),
                          icon: const Icon(Icons.directions),
                          label: const Text('Mulai Navigasi'),
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50)),
                        ),
                        const Divider(thickness: 1),
                        const SizedBox(height: 20),
                        const SectionTitle(title: 'Ulasan & Rating'),
                        const SizedBox(height: 12),
                        if (kos.reviews.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: kos.reviews.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final review = kos.reviews[index];
                              return ReviewCard(review: review);
                            },
                          )
                        else
                          Text('Belum ada ulasan untuk kos ini.',
                              style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implementasi kontak pemilik
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: const Text('Hubungi Pemilik',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                        const SizedBox(height: 40),
                        const Divider(thickness: 1),
                        const SizedBox(height: 20),
                        const SectionTitle(title: 'Kirim Ulasan Anda'),
                        const SizedBox(height: 20),
                        ReviewForm(
                          formKey: _formKey,
                          authorController: _authorNameController,
                          commentController: _commentController,
                          selectedRating: _selectedRating,
                          onRatingChanged: (val) =>
                              setState(() => _selectedRating = val),
                          onSubmit: _submitReview,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );
}

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const FacilityItem({Key? key, required this.icon, required this.text})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = Colors.blue.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.blue.shade50, borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({Key? key, required this.review}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(review.authorName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(review.comment),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(review.rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class ReviewForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController authorController;
  final TextEditingController commentController;
  final int selectedRating;
  final void Function(int) onRatingChanged;
  final VoidCallback onSubmit;

  const ReviewForm({
    Key? key,
    required this.formKey,
    required this.authorController,
    required this.commentController,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: authorController,
            decoration: const InputDecoration(
              labelText: 'Nama Anda',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Nama tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Ulasan Anda',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.isEmpty)
                ? 'Ulasan tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Rating:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 12),
              ...List.generate(5, (index) {
                return IconButton(
                  iconSize: 28,
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber.shade600,
                  ),
                  onPressed: () => onRatingChanged(index + 1),
                  tooltip: '${index + 1} bintang',
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              backgroundColor: Colors.blue.shade700,
            ),
            child: const Text('Kirim Ulasan',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
