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
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: _padding)),
          BlocBuilder<FriendsCubit, FriendsState>(
            builder: (context, state) {
              switch (state) {
                case FriendsLoading():
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                case FriendsLoaded():
                  return SliverList.builder(
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
                  );

                case FriendsError():
                  return SliverToBoxAdapter(
                    child: Column(
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
                    ),
                  );
              }
            },
          ),
          // const SliverToBoxAdapter(
          //   child: Divider(
          //     color: Palette.neutral400,
          //     height: 16,
          //   ),
          // ),
          // BlocBuilder<ServiceCubit, ServiceState>(
          //   builder: (context, state) {
          //     switch (state) {
          //       case ServicesLoading():
          //         return const SliverToBoxAdapter(
          //           child: Center(child: CircularProgressIndicator.adaptive()),
          //         );
          //       case ServicesLoaded():
          //         return SliverList.builder(
          //           itemCount: state.services.length,
          //           itemBuilder: (context, index) {
          //             return ListTile(
          //               title: Text(state.services[index].name),
          //               subtitle: Text(state.services[index].phone),
          //               onTap: () {},
          //               leading: Container(
          //                 decoration: BoxDecoration(
          //                   shape: BoxShape.circle,
          //                   image: DecorationImage(
          //                     image: AssetImage(
          //                       state.services[index].type == ServiceType.mvd
          //                           ? AppIcons.mvdIcon
          //                           : AppIcons.shelterIcon,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         );

          //       case ServicesError():
          //         return SliverToBoxAdapter(
          //           child: Column(
          //             children: [
          //               const SizedBox(height: _padding),
          //               Text(
          //                 state.error,
          //                 textAlign: TextAlign.center,
          //                 style: const TextStyle(
          //                   color: Colors.red,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         );
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
