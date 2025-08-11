class PropertyFilter {
  final String? search;
  final String? status;
  final double? priceMax;
  final List<String>? facilities;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? category;

  const PropertyFilter({
    this.search,
    this.status,
    this.priceMax,
    this.facilities,
    this.latitude,
    this.longitude,
    this.radius,
    this.category,
  });
}

String getFullImageUrl(String url) {
  if (url.startsWith('http')) {
    return url;
  }
  return 'http://$url';
}
