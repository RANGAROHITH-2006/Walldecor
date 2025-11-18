// ignore_for_file: must_be_immutable

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class SessionRequest extends AuthEvent {
  final Function(User) onSuccess;
  final Function(String)? onError;
  const SessionRequest({required this.onSuccess, this.onError});

  @override
  List<Object?> get props => [onSuccess, onError];
}

class GuestLogin extends AuthEvent {
  final String deviceId;
  final String pushToken;

  final Function(User) onSuccess;
  final Function(String) onError;

  const GuestLogin({
    required this.deviceId,
    required this.pushToken,
    required this.onSuccess,
    required this.onError,
  }) : super();

  @override
  List<Object?> get props => [
        deviceId,
        pushToken,
        onSuccess,
        onError,
      ];
}

class LoginWithGoogle extends AuthEvent {
  final String firstName;
  final String lastName;
  final String googleIdToken;
  final String deviceId;
  final String email;
  final String firebaseUserId;
  final String pushToken;
  final Function(User) onSuccess;
  final Function(String) onError;

  const LoginWithGoogle({
    required this.firstName,
    required this.lastName,
    required this.googleIdToken,
    required this.deviceId,
    required this.email,
    required this.firebaseUserId,
    required this.pushToken,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        deviceId,
        firebaseUserId,
        pushToken,
        onSuccess,
        googleIdToken,
        onError,
      ];
}

class LogOutRequest extends AuthEvent {
  final String fcmToken;
  final VoidCallback onSuccess;

  const LogOutRequest({
    required this.fcmToken,
    required this.onSuccess,
  });

  @override
  List<Object?> get props => [fcmToken, onSuccess];
}

class DeleteUser extends AuthEvent {
  String userId;
  final Function(dynamic) onSuccess;
  final Function(String) onError;
  DeleteUser({
    required this.userId,
    required this.onSuccess,
    required this.onError,
  });

  @override
  List<Object> get props => [userId, onSuccess, onError];
}

class SetLoginInitial extends AuthEvent {
  const SetLoginInitial();

  @override
  List<Object?> get props => [];
}