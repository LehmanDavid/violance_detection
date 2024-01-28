import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:violence_detector/core/network/api_routes.dart';
import 'package:violence_detector/core/network/dio_client.dart';
import 'package:violence_detector/domain/repositories/i_prediction.dart';

@LazySingleton(as: IPrediction)
final class PredictionRepository implements IPrediction {
  final DioClient _client;

  const PredictionRepository(this._client);

  @override
  Future<Map<String, dynamic>> getPrediction(String videoPath) async {
    // Obtain current location
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
 
    // Prepare data for the POST request
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(videoPath),
    });

    // Make the POST request
    final response = await _client.post(
      ApiRoutes.prediction,
      queryParameters: {
        'id': 6,
        'lat': position.latitude,
        'lon': position.longitude,
      },
      data: formData,
    );

    return response.data;
  }
}
