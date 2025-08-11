import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/services/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'property_detail_provider.g.dart'; // File yang akan di-generate

@riverpod
Future<Property> propertyDetail(
  PropertyDetailRef ref,
  int propertyId, // Parameter untuk ID properti
) async {
  // Panggil service untuk mengambil detail properti
  return ApiService.getPropertyDetail(propertyId);
}
