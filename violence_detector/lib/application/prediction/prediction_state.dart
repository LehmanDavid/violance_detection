part of 'prediction_cubit.dart';

@immutable
sealed class VideoUploadState {
  const VideoUploadState();
}

final class VideoInitial extends VideoUploadState {
  const VideoInitial();
}

final class VideoUploadLoading extends VideoUploadState {
  const VideoUploadLoading();
}

final class VideoUploadSuccess extends VideoUploadState {
  final Map<String, dynamic> result;
  const VideoUploadSuccess({required this.result});
}

final class VideoUploadError extends VideoUploadState {
  final String error;

  const VideoUploadError({required this.error});
}
