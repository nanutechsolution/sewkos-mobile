import 'package:intl/intl.dart';

// const String baseUrl = 'https://sewkos-api.rskaritas.com';
const String baseUrl = 'http://192.168.93.106:8000';
String _formatRupiah(String price) {
  try {
    double value =
        double.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  } catch (_) {
    return price;
  }
}

String getFullImageUrl(String url) {
  if (url.startsWith('/storage') || url.startsWith('/assets')) {
    return '$baseUrl$url';
  }
  if (url.startsWith(baseUrl)) {
    return url; // jangan tambah port lagi
  }
  // fallback replace IP dan port
  return url.replaceAll(
      RegExp(r'http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?'), baseUrl);
}
