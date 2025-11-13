import 'package:equatable/equatable.dart';
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}
/// Event to check if guest token exists in SharedPreferences
class CheckGuestEvent extends AuthEvent {
  const CheckGuestEvent();
}


class CreateGuestEvent extends AuthEvent {
  const CreateGuestEvent();
}

class LoginWithGoogleEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String firebaseUserId;
  final String pushToken;
  final String deviceId;
  final String idToken;

  const LoginWithGoogleEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.firebaseUserId,
    required this.pushToken,
    required this.deviceId,
    required this.idToken,
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    email,
    firebaseUserId,
    pushToken,
    deviceId,
    idToken,
  ];
}

/// Event to logout (remove tokens)
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}