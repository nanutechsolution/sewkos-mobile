import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/services/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'property_list_provider.g.dart';

@riverpod
Future<List<Property>> propertyList(
  PropertyListRef ref, {
  String? search,
  String? status = 'kosong',
  double? priceMax,
  List<String>? facilities,
  double? latitude,
  double? longitude,
  double? radius,
  String? category,
}) async {
  return ApiService.getPropertiesList(
    search: search,
    status: status,
    priceMax: priceMax,
    facilities: facilities,
    latitude: latitude,
    longitude: longitude,
    radius: radius,
  );
}
