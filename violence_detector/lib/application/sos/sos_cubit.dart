import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:violence_detector/core/injection/injection.dart';
import 'package:violence_detector/domain/repositories/i_sos.dart';

part 'sos_state.dart';

class SosCubit extends Cubit<SosState> {
  final _repo = getIt.get<ISOS>();

  SosCubit() : super(const SosInitial());

  Future<void> getReady() async {
    emit(const SosSending());
  }

  Future<void> sendSOS(bool status) async {
    try {
      final result = await _repo.sendSOS(status);

      emit(SosSent(result));
    } catch (e) {
      if (e is DioException) {
        return emit(SosError(error: e.message ?? ''));
      }

      emit(SosError(error: e.toString()));
    }
  }
}
