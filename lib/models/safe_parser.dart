import 'dart:convert';

double? parseDoubleSafely(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    if (value.toLowerCase() == 'null') {
      return null;
    }
    return double.tryParse(value);
  }
  return null;
}

List<Map<String, dynamic>> parseListMapSafely(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return [];
}

List<int> parseListIntSafely(dynamic value) {
  if (value is List) {
    return value.whereType<int>().toList();
  } else if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.whereType<int>().toList();
      }
    } catch (e) {}
  }
  return [];
}
