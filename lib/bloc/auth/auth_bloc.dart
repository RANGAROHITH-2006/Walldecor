import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<CheckGuestEvent>(_onCheckGuest);
    on<CreateGuestEvent>(_onCreateGuest);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LogoutEvent>(_onLogout);
  }

  /// Handle CheckGuestEvent
  Future<void> _onCheckGuest(
    CheckGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final tokens = await _authRepository.getStoredTokens();
      if (tokens != null) {
        final userType = tokens['userType'];
        
        if (userType == 'guest') {
          emit(GuestAuthenticated(
            guestId: tokens['guestId']!,
            authToken: tokens['authToken']!,
          ));
          print('Guest ID: ${tokens['guestId']}');
          print('Auth Token: ${tokens['authToken']}');
        } else if (userType == 'google') {
          final userData = await _authRepository.getStoredUserData();
          emit(GoogleAuthenticated(
            userId: tokens['guestId']!,
            authToken: tokens['authToken']!,
            email: userData?['email'] ?? '',
            firstName: userData?['firstName'] ?? '',
            lastName: userData?['lastName'] ?? '',
          ));
        }
      } else {
        // No token found, create guest account
        add(const CreateGuestEvent());
      }
    } catch (e) {
      emit(AuthError('Failed to check authentication status: ${e.toString()}'));
    }
  }

  /// Handle CreateGuestEvent
  Future<void> _onCreateGuest(
    CreateGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthLoading) {
      emit(const AuthLoading());
    }
    
    try {
      final result = await _authRepository.createGuestAccount();
      emit(GuestAuthenticated(
        guestId: result['guestId']!,
        authToken: result['authToken']!,
      ));
    } catch (e) {
      emit(AuthError('Failed to create guest account: ${e.toString()}'));
    }
  }

  /// Handle LoginWithGoogleEvent
  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final result = await _authRepository.loginWithGoogle(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        firebaseUserId: event.firebaseUserId,
        pushToken: event.pushToken,
        deviceId: event.deviceId,
        idToken: event.idToken,
      );
      
      emit(GoogleAuthenticated(
        userId: result['userId']!,
        authToken: result['authToken']!,
        email: result['email']!,
        firstName: result['firstName']!,
        lastName: result['lastName']!,
      ));
    } catch (e) {
      emit(AuthError('Failed to login with Google: ${e.toString()}'));
    }
  }

  /// Handle LogoutEvent
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authRepository.removeAuthData();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthError('Failed to logout: ${e.toString()}'));
    }
  }
}