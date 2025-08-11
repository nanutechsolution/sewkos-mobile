// Halaman search dengan Hero dan fokus input:
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto fokus input keyboard
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(FocusNode());
      FocusScope.of(context).requestFocus(FocusNode());
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'search-bar-hero',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Cari kos, homestay, fasilitas...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: Text(
          'Hasil pencarian akan muncul di sini...',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
