import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:violence_detector/core/injection/injection.dart';

import '../../domain/repositories/i_prediction.dart';
part 'prediction_state.dart';

class PredictionCubit extends Cubit<VideoUploadState> {
  final _predictionRepository = getIt<IPrediction>();

  PredictionCubit() : super(const VideoInitial());

  Future<void> getPrediction({required String videoPath}) async {
    emit(const VideoUploadLoading());
    try {
      final result = await _predictionRepository.getPrediction(videoPath);
      emit(VideoUploadSuccess(result: result));
    } catch (e) {
      if (e is DioException) {
        return emit(VideoUploadError(error: e.message ?? ''));
      }

      emit(VideoUploadError(error: e.toString()));
    }
  }
}
