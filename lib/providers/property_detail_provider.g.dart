// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$propertyDetailHash() => r'3eb4a1549ab5fdbe8efa95d68161a8b4707968c1';

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

/// See also [propertyDetail].
@ProviderFor(propertyDetail)
const propertyDetailProvider = PropertyDetailFamily();

/// See also [propertyDetail].
class PropertyDetailFamily extends Family<AsyncValue<Property>> {
  /// See also [propertyDetail].
  const PropertyDetailFamily();

  /// See also [propertyDetail].
  PropertyDetailProvider call(
    int propertyId,
  ) {
    return PropertyDetailProvider(
      propertyId,
    );
  }

  @override
  PropertyDetailProvider getProviderOverride(
    covariant PropertyDetailProvider provider,
  ) {
    return call(
      provider.propertyId,
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
  String? get name => r'propertyDetailProvider';
}

/// See also [propertyDetail].
class PropertyDetailProvider extends AutoDisposeFutureProvider<Property> {
  /// See also [propertyDetail].
  PropertyDetailProvider(
    int propertyId,
  ) : this._internal(
          (ref) => propertyDetail(
            ref as PropertyDetailRef,
            propertyId,
          ),
          from: propertyDetailProvider,
          name: r'propertyDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$propertyDetailHash,
          dependencies: PropertyDetailFamily._dependencies,
          allTransitiveDependencies:
              PropertyDetailFamily._allTransitiveDependencies,
          propertyId: propertyId,
        );

  PropertyDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.propertyId,
  }) : super.internal();

  final int propertyId;

  @override
  Override overrideWith(
    FutureOr<Property> Function(PropertyDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PropertyDetailProvider._internal(
        (ref) => create(ref as PropertyDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        propertyId: propertyId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Property> createElement() {
    return _PropertyDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PropertyDetailProvider && other.propertyId == propertyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, propertyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PropertyDetailRef on AutoDisposeFutureProviderRef<Property> {
  /// The parameter `propertyId` of this provider.
  int get propertyId;
}

class _PropertyDetailProviderElement
    extends AutoDisposeFutureProviderElement<Property> with PropertyDetailRef {
  _PropertyDetailProviderElement(super.provider);

  @override
  int get propertyId => (origin as PropertyDetailProvider).propertyId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
