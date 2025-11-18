part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  success,
  failure,
  loading,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? token;
  final String? message;
  final User? user;

   const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.message,
     this.user,
  });

  AuthState copyWith(
      {AuthStatus? status, User? user, String? token, String? message}) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, token, message, user];
}

class AuthInitial extends AuthState {
   const AuthInitial() : super(status: AuthStatus.initial);
}