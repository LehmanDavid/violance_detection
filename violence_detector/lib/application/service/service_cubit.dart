import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:violence_detector/domain/entities/service_entity.dart';
import 'package:violence_detector/domain/repositories/I_services.dart';

import '../../core/injection/injection.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final _repo = getIt.get<IServices>();

  ServiceCubit() : super(const ServicesLoading());

  Future<void> getServices() async {
    try {
      final result = await _repo.getServices();

      emit(ServicesLoaded(services: result));
    } catch (e) {
      if (e is DioException) {
        return emit(ServicesError(error: e.message ?? ''));
      }

      emit(ServicesError(error: e.toString()));
    }
  }
}
