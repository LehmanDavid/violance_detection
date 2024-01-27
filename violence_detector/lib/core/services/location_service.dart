import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class LocationService {
  Future<Position> _determinePosition() async {
    final lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      return lastKnownPosition;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>?> getLocation() async {
    final isPermissionGranted = await Geolocator.checkPermission();

    switch (isPermissionGranted) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return _determinePosition().then((value) => {
              'lat': value.latitude,
              'lon': value.longitude,
              'alt': value.altitude,
            });

      default:
        await Geolocator.requestPermission();

        return getLocation();
    }
  }
}
