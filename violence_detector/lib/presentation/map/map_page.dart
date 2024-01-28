import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:violence_detector/application/friends/friends_cubit.dart';
import 'package:violence_detector/application/service/service_cubit.dart';
import 'package:violence_detector/core/injection/injection.dart';
import 'package:violence_detector/core/services/location_service.dart';
import 'package:violence_detector/core/ui/consts/app_icons.dart';
import 'package:violence_detector/core/ui/theme/palette.dart';
import 'package:violence_detector/domain/entities/service_entity.dart';
import 'package:violence_detector/domain/entities/service_type.dart';
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
  String _locationName = '';
  // final _mapObjects = <MapObject>[];
  // final _tashkent = const Point(latitude: 41.2995, longitude: 69.2401);

  double _mapZoom = 0.0;

  // void _addMarkers() {
  //   final placemark = PlacemarkMapObject(
  //     mapId: MapObjectId(_tashkent.latitude.toString()),
  //     point: _tashkent,
  //   );

  // }

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
          _locationName = items.first.name;
        });
      }
    });
  }

  ClusterizedPlacemarkCollection _getClusterizedServiceCollection({
    required List<PlacemarkMapObject> placemarks,
  }) {
    return ClusterizedPlacemarkCollection(
        mapId: const MapObjectId('clusterized-1'),
        placemarks: placemarks,
        radius: 50,
        minZoom: 15,
        onClusterAdded: (self, cluster) async {
          return cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              opacity: 1.0,
            ),
          );
        },
        onClusterTap: (self, cluster) async {
          await _mapController?.moveCamera(
            animation: const MapAnimation(
              type: MapAnimationType.linear,
              duration: 0.3,
            ),
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: cluster.placemarks.first.point,
                zoom: _mapZoom + 1,
              ),
            ),
          );
        });
  }

  ClusterizedPlacemarkCollection _getClusterizedFriendsCollection({
    required List<PlacemarkMapObject> placemarks,
  }) {
    return ClusterizedPlacemarkCollection(
        mapId: const MapObjectId('clusterized-2'),
        placemarks: placemarks,
        radius: 10,
        minZoom: 15,
        onClusterAdded: (self, cluster) async {
          return cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              opacity: 1.0,
            ),
          );
        },
        onClusterTap: (self, cluster) async {
          await _mapController?.moveCamera(
            animation: const MapAnimation(
              type: MapAnimationType.linear,
              duration: 0.3,
            ),
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: cluster.placemarks.first.point,
                zoom: _mapZoom + 1,
              ),
            ),
          );
        });
  }

  List<PlacemarkMapObject> _getPlacemarkServiceObjects(
    BuildContext context,
    List<ServiceEntity> services,
  ) {
    return services
        .map(
          (service) => PlacemarkMapObject(
            mapId: MapObjectId('MapObject $service'),
            point: Point(latitude: service.lat, longitude: service.lon),
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  service.type == ServiceType.mvd
                      ? AppIcons.mvdIcon
                      : AppIcons.shelterIcon,
                ),
                scale: 1,
              ),
            ),
            onTap: (_, __) => showModalBottomSheet(
              context: context,
              constraints: const BoxConstraints.expand(
                width: double.maxFinite,
                height: 250,
              ),
              builder: (context) => ModalBodyView(
                point: service,
              ),
            ),
          ),
        )
        .toList();
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
                color: Palette.primary600,
                size: MapPage._drawerIconSize,
              ),
            );
          }),
        ],
      ),
      endDrawer: const FriendsDrawer(),
      body: Stack(
        children: [
          LocationLabel(locationName: _locationName),
          BlocBuilder<FriendsCubit, FriendsState>(
            builder: (context, friendsState) {
              return BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, serviceState) {
                  return YandexMap(
                    onMapCreated: _onMapCreated,
                    mapObjects: [
                      if (serviceState is ServicesLoaded)
                        _getClusterizedServiceCollection(
                          placemarks: _getPlacemarkServiceObjects(
                            context,
                            serviceState.services,
                          ),
                        ),
                      if (friendsState is FriendsLoaded)
                        _getClusterizedFriendsCollection(
                          placemarks: friendsState.mapObjects,
                        ),
                    ],
                    onUserLocationAdded: (view) async {
                      view.pin;
                      return view;
                    },
                    onCameraPositionChanged: (cameraPosition, _, __) {
                      setState(() {
                        _mapZoom = cameraPosition.zoom;
                      });
                    },
                  );
                },
              );
            },
          ),
        ].reversed.toList(),
      ),
    );
  }
}

class ModalBodyView extends StatefulWidget {
  final ServiceEntity point;

  const ModalBodyView({super.key, required this.point});

  @override
  State<ModalBodyView> createState() => _ModalBodyViewState();
}

class _ModalBodyViewState extends State<ModalBodyView> {
  String _locationName = '';

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    final result = YandexSearch.searchByPoint(
      point: Point(latitude: widget.point.lat, longitude: widget.point.lat),
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
          _locationName = items.first.name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.point.type == ServiceType.mvd
                ? 'Быстрое реагирование'
                : 'Центр помощи',
            style: const TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            widget.point.name,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            widget.point.phone,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _locationName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
