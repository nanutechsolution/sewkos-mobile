import 'package:flutter/material.dart';
import 'package:kossumba_app/config.dart';
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
  final _authorController = TextEditingController();
  final _commentController = TextEditingController();
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchKosDetail();
    _checkFavorite();
  }

  void _fetchKosDetail() {
    setState(() {
      _kosDetailFuture = KosService.getKosDetail(widget.kosId);
    });
  }

  void _checkFavorite() async {
    bool fav = await FavoriteService.isFavorite(widget.kosId);
    setState(() => _isFavorite = fav);
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

  void _launchNavigation(double lat, double lng) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }

  void _submitReview() async {
    if (_formKey.currentState!.validate() && _selectedRating > 0) {
      try {
        await KosService.postReview(
          widget.kosId,
          _authorController.text,
          _commentController.text,
          _selectedRating,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil dikirim!')),
        );
        _authorController.clear();
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

  @override
  void dispose() {
    _authorController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Kos>(
      future: _kosDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(child: Text(snapshot.error.toString())));
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: Text('Kos tidak ditemukan')));
        }

        final kos = snapshot.data!;
        return Scaffold(
          bottomNavigationBar: _BottomActionBar(
            onContact: () {
              // TODO: Kontak pemilik
            },
            onNavigate: () => _launchNavigation(kos.latitude!, kos.longitude!),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                stretch: true,
                title: Text(kos.name),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'kos-image-${kos.id}', // Hero animation
                        child: Image.network(
                          getFullImageUrl(kos.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 200),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kos.location,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      _SectionTitle('Deskripsi'),
                      Text(kos.description,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 20),
                      _SectionTitle('Fasilitas'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: kos.facilities
                            .map((f) => _FacilityChip(text: f))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle('Ulasan & Rating'),
                      if (kos.reviews.isNotEmpty)
                        Column(
                          children:
                              kos.reviews.map((r) => _ReviewCard(r)).toList(),
                        )
                      else
                        Text('Belum ada ulasan',
                            style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 30),
                      _SectionTitle('Kirim Ulasan Anda'),
                      ReviewForm(
                        formKey: _formKey,
                        authorController: _authorController,
                        commentController: _commentController,
                        selectedRating: _selectedRating,
                        onRatingChanged: (v) =>
                            setState(() => _selectedRating = v),
                        onSubmit: _submitReview,
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ====== WIDGET REUSABLE ======

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontWeight: FontWeight.bold));
  }
}

class _FacilityChip extends StatelessWidget {
  final String text;
  const _FacilityChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue.shade50,
      avatar:
          const Icon(Icons.check_circle_outline, color: Colors.blue, size: 18),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard(this.review);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(review.authorName),
        subtitle: Text(review.comment),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber),
            Text(review.rating.toString()),
          ],
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onContact;
  final VoidCallback onNavigate;
  const _BottomActionBar({
    required this.onContact,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Hubungi Pemilik'),
              onPressed: onContact,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text('Navigasi'),
              onPressed: onNavigate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== FORM REVIEW =====
class ReviewForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController authorController;
  final TextEditingController commentController;
  final int selectedRating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const ReviewForm({
    required this.formKey,
    required this.authorController,
    required this.commentController,
    required this.selectedRating,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: authorController,
            decoration: const InputDecoration(labelText: 'Nama Anda'),
            validator: (value) =>
                value!.isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: commentController,
            decoration: const InputDecoration(labelText: 'Komentar'),
            validator: (value) =>
                value!.isEmpty ? 'Komentar tidak boleh kosong' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => onRatingChanged(index + 1),
              );
            }),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Kirim Ulasan'),
          ),
        ],
      ),
    );
  }
}
