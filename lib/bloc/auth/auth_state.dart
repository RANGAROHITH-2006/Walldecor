import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state when the bloc is created
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state when API call is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Success state when guest account is created
class GuestAuthenticated extends AuthState {
  final String guestId;
  final String authToken;

  const GuestAuthenticated({
    required this.guestId,
    required this.authToken,
  });

  @override
  List<Object> get props => [guestId, authToken];
}

/// Success state when Google login is successful
class GoogleAuthenticated extends AuthState {
  final String userId;
  final String authToken;
  final String email;
  final String firstName;
  final String lastName;

  const GoogleAuthenticated({
    required this.userId,
    required this.authToken,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [userId, authToken, email, firstName, lastName];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}