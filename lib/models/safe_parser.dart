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
