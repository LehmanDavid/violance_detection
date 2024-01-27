part of 'sos_cubit.dart';

@immutable
sealed class SosState {
  const SosState();
}

final class SosInitial extends SosState {
  const SosInitial();
}

final class SosSending extends SosState {
  const SosSending();
}

final class SosSent extends SosState {
  final bool status;
  const SosSent(this.status);
}

final class SosError extends SosState {
  final String error;

  const SosError({required this.error});
}
