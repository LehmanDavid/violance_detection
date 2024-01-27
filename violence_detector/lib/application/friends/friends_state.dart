part of 'friends_cubit.dart';

@immutable
sealed class FriendsState {
  const FriendsState();
}

final class FriendsLoading extends FriendsState {
  const FriendsLoading();
}

final class FriendsLoaded extends FriendsState {
  final List<FriendEntity> friends;
  const FriendsLoaded({required this.friends});
}

final class FriendsError extends FriendsState {
  final String error;

  const FriendsError({required this.error});
}
