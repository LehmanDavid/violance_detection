import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:violence_detector/application/friends/friends_cubit.dart';

class FriendsDrawer extends StatelessWidget {
  static const double _padding = 50;
  static const double _imageBorderWidth = 1;

  const FriendsDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<FriendsCubit, FriendsState>(
        builder: (context, state) {
          switch (state) {
            case FriendsLoading():
              return const Center(child: CircularProgressIndicator.adaptive());
            case FriendsLoaded():
              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: _padding)),
                  SliverList.builder(
                    itemCount: state.friends.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.friends[index].name),
                        subtitle: Text(state.friends[index].phone),
                        onTap: () {},
                        leading: CircleAvatar(
                          backgroundColor:
                              state.friends[index].isAlert ? Colors.red : null,
                          child: Padding(
                            padding: const EdgeInsets.all(_imageBorderWidth),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    state.friends[index].profileImg,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );

            case FriendsError():
              return Column(
                children: [
                  const SizedBox(height: _padding),
                  Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
