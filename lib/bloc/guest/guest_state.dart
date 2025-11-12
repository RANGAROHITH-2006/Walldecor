import 'package:equatable/equatable.dart';

abstract class GuestState extends Equatable {
  const GuestState();

  @override
  List<Object> get props => [];
}

/// Initial state when the bloc is created
class GuestInitial extends GuestState {
  const GuestInitial();
}

/// Loading state when API call or SharedPreferences operation is in progress
class GuestLoading extends GuestState {
  const GuestLoading();
}

/// Success state when guest token is available
class GuestCreated extends GuestState {
  final String token;
  const GuestCreated(this.token);

  @override
  List<Object> get props => [token];
}

/// Error state when something goes wrong
class GuestError extends GuestState {
  final String message;

  const GuestError(this.message);

  @override
  List<Object> get props => [message];
}