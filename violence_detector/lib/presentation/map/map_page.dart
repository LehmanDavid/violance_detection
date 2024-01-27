import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:violence_detector/application/sos/sos_cubit.dart';
import 'package:violence_detector/core/injection/injection.dart';
import 'package:violence_detector/core/services/location_service.dart';
import 'package:violence_detector/presentation/map/widgets/intention_modal.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'widgets/friends_drawer.dart';
import 'widgets/location_label.dart';

class MapPage extends StatefulWidget {
  static const double _mapAnimationDuration = 2;
  static const double _drawerIconSize = 30;

  final bool isSending;

  const MapPage({super.key, required this.isSending});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  YandexMapController? _mapController;
  String locationName = '';
  final List<MapObject> mapObjects = [];
  final Point tashkent = const Point(latitude: 41.2995, longitude: 69.2401);

  @override
  void initState() {
    _addMarkers();
    super.initState();
  }

  void _addMarkers() {
    final placemark = PlacemarkMapObject(
      mapId: MapObjectId(tashkent.latitude.toString()),
      point: tashkent,
    );
    mapObjects.add(placemark);
  }

  Future<void> _onMapCreated(YandexMapController controller) async {
    _mapController = controller;
    controller.moveCamera(
      CameraUpdate.zoomIn(),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: MapPage._mapAnimationDuration,
      ),
    );

    final location = await getIt.get<LocationService>().getLocation();

    final locationPoint = Point(
      latitude: location!['lat'],
      longitude: location['lon'],
    );
    final geometry = Geometry.fromBoundingBox(BoundingBox(
      northEast: locationPoint,
      southWest: locationPoint,
    ));

    await controller.moveCamera(
      CameraUpdate.newGeometry(geometry),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: MapPage._mapAnimationDuration,
      ),
    );

    _mapController?.toggleUserLayer(
      visible: true,
      autoZoomEnabled: true,
    );

    final result = YandexSearch.searchByPoint(
      point: locationPoint,
      searchOptions: const SearchOptions(),
    );

    result.result.then((value) {
      final items = value.items;
      if (items != null) {
        // String name = '';
        // for (final element in items) {
        //   name = name + element.name;
        // }

        setState(() {
          locationName = items.first.name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.deepOrange,
                size: MapPage._drawerIconSize,
              ),
            );
          }),
        ],
      ),
      endDrawer: const FriendsDrawer(),
      body: BlocListener<SosCubit, SosState>(
        listener: (context, state) {
          if (state is SosSending) {
            if (widget.isSending) {
              showBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return const IntentionModal();
                  });
            }
          }
        },
        child: Stack(
          children: [
            LocationLabel(locationName: locationName),
            YandexMap(
              mapObjects: mapObjects,
              onUserLocationAdded: (view) async {
                view.pin;
                return view;
              },
              onMapCreated: _onMapCreated,
            ),
          ].reversed.toList(),
        ),
      ),
    );
  }
}
