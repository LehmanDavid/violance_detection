import 'package:violence_detector/domain/entities/service_entity.dart';

abstract interface class IServices {
  Future<List<ServiceEntity>> getServices();
}
