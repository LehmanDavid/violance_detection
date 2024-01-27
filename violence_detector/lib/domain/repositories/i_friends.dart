import 'package:violence_detector/domain/entities/friend_entity.dart';

abstract interface class IFriends {
  Future<List<FriendEntity>> getFriends();
}
