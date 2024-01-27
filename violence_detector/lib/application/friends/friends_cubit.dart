import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:violence_detector/core/injection/injection.dart';
import 'package:violence_detector/domain/entities/friend_entity.dart';
import 'package:violence_detector/domain/repositories/i_friends.dart';

part 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final _repo = getIt.get<IFriends>();

  FriendsCubit() : super(const FriendsLoading());

  Future<void> getFriends() async {
    try {
      final result = await _repo.getFriends();

      emit(FriendsLoaded(friends: result));
    } catch (e) {
      if (e is DioException) {
        return emit(FriendsError(error: e.message ?? ''));
      }

      emit(FriendsError(error: e.toString()));
    }
  }
}
