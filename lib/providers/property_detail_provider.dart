import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/services/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'property_detail_provider.g.dart';

@riverpod
Future<Property> propertyDetail(
  PropertyDetailRef ref,
  int propertyId,
) async {
  return ApiService.getPropertyDetail(propertyId);
}
