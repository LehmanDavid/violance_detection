import 'package:injectable/injectable.dart';
import 'package:violence_detector/core/network/api_routes.dart';
import 'package:violence_detector/core/network/dio_client.dart';
import 'package:violence_detector/infrastructure/dto/service_model.dart';

import '../../domain/repositories/I_services.dart';

@LazySingleton(as: IServices)
final class ServicesRepository implements IServices {
  final DioClient _client;

  const ServicesRepository(this._client);

  @override
  Future<List<ServiceModel>> getServices() async {
    final response = await _client.get(ApiRoutes.organizations);

    return ServiceModel.buildList(response.data);
  }
}
