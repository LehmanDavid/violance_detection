import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:violence_detector/application/friends/friends_cubit.dart';
import 'package:violence_detector/application/prediction/prediction_cubit.dart';
import 'package:violence_detector/application/service/service_cubit.dart';
import 'package:violence_detector/application/sos/sos_cubit.dart';

import 'package:violence_detector/presentation/map/map_page.dart';
import 'package:violence_detector/presentation/sos/sos_page.dart';
import 'routes.dart';

final class AppRouter {
  final GoRouter _router;

  AppRouter() : _router = _init();

  GoRouter get router => _router;

  static GoRouter _init() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: Routes.sos.name,
          routes: [
            GoRoute(
              path: 'map',
              name: Routes.map.name,
              pageBuilder: (context, state) {
                final map = state.extra! as Map;
                final sosCubit = map['cubit'] as SosCubit;
                final bool isSending = map['isSending'] ?? false;

                return MaterialPage(
                  name: Routes.map.name,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: sosCubit),
                      BlocProvider(
                        create: (context) => ServiceCubit()..getServices(),
                      ),
                      BlocProvider(
                        create: (context) => FriendsCubit()..getFriends(),
                      ),
                    ],
                    child: MapPage(isSending: isSending),
                  ),
                );
              },
            ),
          ],
          pageBuilder: (context, state) {
            return MaterialPage(
              name: Routes.sos.name,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => SosCubit(),
                  ),
                  BlocProvider(
                    create: (context) => PredictionCubit(),
                  )
                ],
                child: const SOSPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
