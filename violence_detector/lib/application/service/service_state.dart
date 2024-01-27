part of 'service_cubit.dart';

sealed class ServiceState {
  const ServiceState();
}

final class ServicesLoading extends ServiceState {
  const ServicesLoading();
}

final class ServicesLoaded extends ServiceState {
  final List<ServiceEntity> services;

  const ServicesLoaded({required this.services});
}

final class ServicesError extends ServiceState {
  final String error;

  const ServicesError({required this.error});
}
