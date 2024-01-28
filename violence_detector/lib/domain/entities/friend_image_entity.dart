import 'package:violence_detector/domain/entities/friend_entity.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

final class FriendImageEntity {
  final FriendEntity friend;
  final BitmapDescriptor imageBytes;

  const FriendImageEntity({required this.friend, required this.imageBytes});
}
