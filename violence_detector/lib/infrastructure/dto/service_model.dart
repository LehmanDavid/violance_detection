import 'package:flutter/foundation.dart';
import 'package:violence_detector/domain/entities/service_type.dart';
import '../../domain/entities/service_entity.dart';

@immutable
final class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.name,
    required super.phone,
    required super.type,
    required super.lat,
    required super.lon,
  });

  factory ServiceModel.buildModel(Map<String, dynamic> data) {
    return ServiceModel(
        name: data['name'] ?? '',
        phone: data['phone'] ?? '',
        lat: data['lat'] ?? 0,
        lon: data['lon'] ?? 0,
        type: _getServiceType(data['type']));
  }

  static ServiceType _getServiceType(String? type) {
    switch (type) {
      case 'shelter':
        return ServiceType.shelter;
      default:
        return ServiceType.mvd;
    }
  }

  static List<ServiceModel> buildList(List? data) {
    if (data == null) {
      return [];
    }

    final list = <ServiceModel>[];

    for (final el in data) {
      list.add(ServiceModel.buildModel(el));
    }

    return list;
  }
}
