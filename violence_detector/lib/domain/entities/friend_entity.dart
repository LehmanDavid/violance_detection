import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
base class FriendEntity extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String profileImg;
  final double lat;
  final double lon;
  final bool isAlert;

  const FriendEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.profileImg,
    required this.lat,
    required this.lon,
    required this.isAlert,
  });
  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        profileImg,
        lat,
        lon,
        isAlert,
      ];
}
