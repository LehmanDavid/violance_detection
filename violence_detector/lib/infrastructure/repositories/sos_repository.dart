import 'package:injectable/injectable.dart';
import 'package:violence_detector/core/network/api_routes.dart';
import 'package:violence_detector/core/network/dio_client.dart';

import '../../domain/repositories/i_sos.dart';

@LazySingleton(as: ISOS)
final class SOSRepository implements ISOS {
  final DioClient _client;

  const SOSRepository(this._client);

  @override
  Future<bool> sendSOS(bool status) async {
    final response = await _client.put(
      ApiRoutes.sos,
      queryParameters: {
        'person_id': 6,
        'is_alert': status,
      },
    );

    return response.data['status'];
  }
}
