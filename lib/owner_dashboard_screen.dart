import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kossumba_app/config.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/owner_login_screen.dart';
import 'package:kossumba_app/owner_screen.dart';
import 'package:kossumba_app/owner_service.dart';
import 'package:kossumba_app/auth_service.dart';
import 'package:kossumba_app/user_profile_screen.dart';
import 'package:kossumba_app/kos_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Kos>> _ownerKosListFuture;
  String _filter = 'semua'; // semua | kosong | terisi
  String _sort = 'terbaru'; // sederhana: terbaru / nama
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadKosList();
  }

  void _loadKosList() {
    _ownerKosListFuture = OwnerService.fetchOwnerKosList().catchError((error) {
      final errStr = error.toString().toLowerCase();
      if (errStr.contains('token tidak valid') ||
          errStr.contains('tidak terautentikasi') ||
          errStr.contains('kedaluwarsa')) {
        AuthService.logout();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
          );
        }
      }
      throw error;
    });
    setState(() {});
  }

  Future<void> _confirmDelete(int kosId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yakin nih?'),
        content: const Text('Kamu mau hapus kos ini? Gak bisa dibalikin loh.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await OwnerService.deleteKos(kosId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil hapus kos!')),
          );
        }
        _loadKosList();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal hapus kos: $e')),
          );
        }
      }
    } else {
      // jika batal, reload list biar item tidak hilang di UI
      _loadKosList();
    }
  }

  Future<void> _toggleKosStatus(Kos kos) async {
    final newStatus = kos.status == 'kosong' ? 'terisi' : 'kosong';
    try {
      await OwnerService.updateKosStatus(kos.id, newStatus);
      _loadKosList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Status kos berhasil diubah menjadi ${newStatus.toUpperCase()}.')),
        );
      }
    } catch (e) {
      final lower = e.toString().toLowerCase();
      if (lower.contains('token tidak valid') ||
          lower.contains('kedaluwarsa')) {
        AuthService.logout();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e')),
        );
      }
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
      );
    }
  }

  List<Kos> _applyFilterAndSort(List<Kos> list) {
    var filtered = list;
    if (_filter == 'kosong') {
      filtered = list.where((k) => k.status == 'kosong').toList();
    } else if (_filter == 'terisi') {
      filtered = list.where((k) => k.status == 'terisi').toList();
    } else {
      filtered = List.from(list);
    }

    if (_sort == 'nama') {
      filtered
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      // default 'terbaru' as-is (server should return newest first). if not, we can reverse or sort by id/date if available.
    }
    return filtered;
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
          ),
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, Kos kos) {
    return Slidable(
      key: ValueKey(kos.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) async {
              // Edit
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OwnerScreen(kosToEdit: kos)),
              );
              _loadKosList();
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (ctx) => _confirmDelete(kos.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_forever,
            label: 'Hapus',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => KosDetailScreen(kosId: kos.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image with hero
              Hero(
                tag: 'kos-image-${kos.id}',
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    getFullImageUrl(kos.imageUrl),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.house_outlined)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Text(
                  kos.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  kos.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Animated status pill
                    GestureDetector(
                      onTap: () => _toggleKosStatus(kos),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kos.status == 'kosong'
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              kos.status == 'kosong'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color: kos.status == 'kosong'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              kos.status.toUpperCase(),
                              style: TextStyle(
                                color: kos.status == 'kosong'
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // mini kebab menu (edit)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.more_vert, size: 18),
                      onPressed: () async {
                        // small menu
                        final sel = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(100, 100, 0, 0),
                          items: [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'hapus', child: Text('Hapus')),
                          ],
                        );
                        if (sel == 'edit') {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => OwnerScreen(kosToEdit: kos)),
                          );
                          _loadKosList();
                        } else if (sel == 'hapus') {
                          _confirmDelete(kos.id);
                        }
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _filter == 'semua',
                  onSelected: (_) {
                    setState(() => _filter = 'semua');
                  },
                ),
                ChoiceChip(
                  label: const Text('Kosong'),
                  selected: _filter == 'kosong',
                  onSelected: (_) {
                    setState(() => _filter = 'kosong');
                  },
                ),
                ChoiceChip(
                  label: const Text('Terisi'),
                  selected: _filter == 'terisi',
                  onSelected: (_) {
                    setState(() => _filter = 'terisi');
                  },
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'terbaru', child: Text('Sort: Terbaru')),
              PopupMenuItem(value: 'nama', child: Text('Sort: Nama')),
            ],
            icon: const Icon(Icons.sort),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kamu'),
        actions: [
          IconButton(
            tooltip: 'Profil Kamu',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OwnerScreen()),
          );
          _loadKosList();
        },
        label: const Text('Tambah Kos'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: FutureBuilder<List<Kos>>(
              future: _ownerKosListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerGrid();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Oops, ada masalah nih: ${snapshot.error}',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: _loadKosList,
                              child: const Text('Coba Lagi')),
                        ],
                      ),
                    ),
                  );
                }
                final kosList = snapshot.data ?? [];
                final displayed = _applyFilterAndSort(kosList);

                if (displayed.isEmpty) {
                  return RefreshIndicator(
                    key: _refreshKey,
                    onRefresh: () async => _loadKosList(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text(
                              'Kamu belum punya kos yang diunggah nih.\nYuk, mulai tambah kos dulu!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  key: _refreshKey,
                  onRefresh: () async => _loadKosList(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: displayed.length,
                    itemBuilder: (context, index) {
                      final kos = displayed[index];
                      return _buildGridItem(context, kos);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
