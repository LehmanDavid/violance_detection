import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:violence_detector/core/injection/injection.dart';
import 'package:violence_detector/core/services/location_service.dart';

import 'core/router/router.dart';
import 'core/ui/theme/theme.dart';

void main() {
  runZonedGuarded(() async {
    configureDependencies();
    runApp(const MyApp());
  }, (error, stack) {
    log(error.toString());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final isGranted = await Permission.locationWhenInUse.isGranted;
    log((await getIt.get<LocationService>().getLocation()).toString());

    if (!isGranted) {
      Permission.locationWhenInUse.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DMD App',
      routerConfig: AppRouter().router,
      theme: AppTheme.theme,
    );
  }
}
