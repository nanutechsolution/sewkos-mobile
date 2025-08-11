// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$propertyListHash() => r'476e7136bff6112cf89dfb1dceeb85a16862312f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [propertyList].
@ProviderFor(propertyList)
const propertyListProvider = PropertyListFamily();

/// See also [propertyList].
class PropertyListFamily extends Family<AsyncValue<List<Property>>> {
  /// See also [propertyList].
  const PropertyListFamily();

  /// See also [propertyList].
  PropertyListProvider call({
    String? search,
    String? status = 'kosong',
    double? priceMax,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    double? radius,
    String? category,
  }) {
    return PropertyListProvider(
      search: search,
      status: status,
      priceMax: priceMax,
      facilities: facilities,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      category: category,
    );
  }

  @override
  PropertyListProvider getProviderOverride(
    covariant PropertyListProvider provider,
  ) {
    return call(
      search: provider.search,
      status: provider.status,
      priceMax: provider.priceMax,
      facilities: provider.facilities,
      latitude: provider.latitude,
      longitude: provider.longitude,
      radius: provider.radius,
      category: provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'propertyListProvider';
}

/// See also [propertyList].
class PropertyListProvider extends AutoDisposeFutureProvider<List<Property>> {
  /// See also [propertyList].
  PropertyListProvider({
    String? search,
    String? status = 'kosong',
    double? priceMax,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    double? radius,
    String? category,
  }) : this._internal(
          (ref) => propertyList(
            ref as PropertyListRef,
            search: search,
            status: status,
            priceMax: priceMax,
            facilities: facilities,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            category: category,
          ),
          from: propertyListProvider,
          name: r'propertyListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$propertyListHash,
          dependencies: PropertyListFamily._dependencies,
          allTransitiveDependencies:
              PropertyListFamily._allTransitiveDependencies,
          search: search,
          status: status,
          priceMax: priceMax,
          facilities: facilities,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
          category: category,
        );

  PropertyListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.search,
    required this.status,
    required this.priceMax,
    required this.facilities,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.category,
  }) : super.internal();

  final String? search;
  final String? status;
  final double? priceMax;
  final List<String>? facilities;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? category;

  @override
  Override overrideWith(
    FutureOr<List<Property>> Function(PropertyListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PropertyListProvider._internal(
        (ref) => create(ref as PropertyListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        search: search,
        status: status,
        priceMax: priceMax,
        facilities: facilities,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Property>> createElement() {
    return _PropertyListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PropertyListProvider &&
        other.search == search &&
        other.status == status &&
        other.priceMax == priceMax &&
        other.facilities == facilities &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radius == radius &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, priceMax.hashCode);
    hash = _SystemHash.combine(hash, facilities.hashCode);
    hash = _SystemHash.combine(hash, latitude.hashCode);
    hash = _SystemHash.combine(hash, longitude.hashCode);
    hash = _SystemHash.combine(hash, radius.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PropertyListRef on AutoDisposeFutureProviderRef<List<Property>> {
  /// The parameter `search` of this provider.
  String? get search;

  /// The parameter `status` of this provider.
  String? get status;

  /// The parameter `priceMax` of this provider.
  double? get priceMax;

  /// The parameter `facilities` of this provider.
  List<String>? get facilities;

  /// The parameter `latitude` of this provider.
  double? get latitude;

  /// The parameter `longitude` of this provider.
  double? get longitude;

  /// The parameter `radius` of this provider.
  double? get radius;

  /// The parameter `category` of this provider.
  String? get category;
}

class _PropertyListProviderElement
    extends AutoDisposeFutureProviderElement<List<Property>>
    with PropertyListRef {
  _PropertyListProviderElement(super.provider);

  @override
  String? get search => (origin as PropertyListProvider).search;
  @override
  String? get status => (origin as PropertyListProvider).status;
  @override
  double? get priceMax => (origin as PropertyListProvider).priceMax;
  @override
  List<String>? get facilities => (origin as PropertyListProvider).facilities;
  @override
  double? get latitude => (origin as PropertyListProvider).latitude;
  @override
  double? get longitude => (origin as PropertyListProvider).longitude;
  @override
  double? get radius => (origin as PropertyListProvider).radius;
  @override
  String? get category => (origin as PropertyListProvider).category;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
