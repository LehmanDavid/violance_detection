import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:violence_detector/domain/entities/friend_entity.dart';
import 'package:violence_detector/domain/entities/friend_image_entity.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final class NetworkImageService {
  static Future<Uint8List> loadNetworkImage(path) async {
    final completed = Completer<ImageInfo>();
    final image = NetworkImage(path);

    image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((info, _) => completed.complete(info)),
        );
    final imageInfo = await completed.future;
    final byteData = await imageInfo.image.toByteData(
      format: ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  static Future<List<FriendImageEntity>> loadData(
    List<FriendEntity> friends,
  ) async {
    final images = <FriendImageEntity>[];

    for (final element in friends) {
      Uint8List image = await NetworkImageService.loadNetworkImage(
        element.profileImg,
      );

      final markerImageCodec = await instantiateImageCodec(
        image.buffer.asUint8List(),
        targetHeight: 150,
        targetWidth: 150,
      );

      final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
      final byteData = await frameInfo.image.toByteData(
        format: ImageByteFormat.png,
      );

      final resizedImageMarker = byteData?.buffer.asUint8List();

      if (resizedImageMarker != null) {
        final desc = BitmapDescriptor.fromBytes(resizedImageMarker);
        images.add(
          FriendImageEntity(friend: element, imageBytes: desc),
        );
      }
    }
    return images;
  }
}
