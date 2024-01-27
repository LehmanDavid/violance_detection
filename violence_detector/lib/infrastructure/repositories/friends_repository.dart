import 'package:injectable/injectable.dart';
import 'package:violence_detector/core/network/api_routes.dart';
import 'package:violence_detector/core/network/dio_client.dart';
import 'package:violence_detector/infrastructure/dto/friend_model.dart';

import '../../domain/repositories/i_friends.dart';

@LazySingleton(as: IFriends)
final class FriendsRepository implements IFriends {
  final DioClient _client;

  const FriendsRepository(this._client);

  @override
  Future<List<FriendModel>> getFriends() async {
    final response = await _client.get(ApiRoutes.people);

    return FriendModel.buildList(response.data['data']);
  }
}
