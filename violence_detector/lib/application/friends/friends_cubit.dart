import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:violence_detector/core/injection/injection.dart';
import 'package:violence_detector/core/services/network_image_service.dart';
import 'package:violence_detector/domain/entities/friend_entity.dart';
import 'package:violence_detector/domain/repositories/i_friends.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

part 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final _repo = getIt.get<IFriends>();

  FriendsCubit() : super(const FriendsLoading());

  Future<List<PlacemarkMapObject>> _getPlacemarkFriendObjects(
    List<FriendEntity> friends,
  ) async {
    final friendsWithImages = await NetworkImageService.loadData(friends);

    return friendsWithImages
        .map(
          (friendWithImage) => PlacemarkMapObject(
            mapId: MapObjectId('MapObject $friendWithImage'),
            point: Point(
                latitude: friendWithImage.friend.lat,
                longitude: friendWithImage.friend.lon),
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: friendWithImage.imageBytes,
                scale: 1,
              ),
            ),
          ),
        )
        .toList();
  }

  Future<void> getFriends() async {
    try {
      final result = await _repo.getFriends();

      final mapObjects = await _getPlacemarkFriendObjects(result);

      emit(FriendsLoaded(friends: result, mapObjects: mapObjects));
    } catch (e) {
      if (e is DioException) {
        return emit(FriendsError(error: e.message ?? ''));
      }

      emit(FriendsError(error: e.toString()));
    }
  }
}
