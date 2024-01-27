import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'service_type.dart';

@immutable
base class ServiceEntity extends Equatable {
  final String name;
  final String phone;
  final ServiceType type;
  final double lat;
  final double lon;

  const ServiceEntity({
    required this.name,
    required this.phone,
    required this.type,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        type,
        lat,
        lon,
      ];
}
