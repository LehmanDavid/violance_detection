import 'package:flutter/material.dart';
import 'package:violence_detector/domain/entities/friend_entity.dart';

@immutable
final class FriendModel extends FriendEntity {
  const FriendModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.profileImg,
    required super.lat,
    required super.lon,
    required super.isAlert,
  });

  factory FriendModel.buildModel(Map<String, dynamic> data) {
    return FriendModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profileImg: data['profile_img'] ?? '',
      lat: data['lat'] ?? 0.0,
      lon: data['lon'] ?? 0.0,
      isAlert: data['is_alert'] ?? false,
    );
  }

  static List<FriendModel> buildList(List? data) {
    if (data == null) {
      return [];
    }

    final list = <FriendModel>[];

    for (final el in data) {
      list.add(FriendModel.buildModel(el));
    }

    return list;
  }
}
