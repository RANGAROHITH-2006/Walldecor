import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/repositories/services/google_auth_service.dart';
import 'package:walldecor/models/userdata_model.dart';

class GoogleAuthHelper {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  /// Perform Google sign-in and trigger BLoC event
  Future<void> signInWithGoogle({
    required BuildContext context,
    required Function(User) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Get Google sign-in data
      final result = await _googleAuthService.signInWithGoogle();
      
      if (result == null) {
        onError('Google sign-in was cancelled');
        return;
      }

      // Trigger BLoC event with the data
      context.read<AuthBloc>().add(
        LoginWithGoogle(
          firstName: result['firstName']!,
          lastName: result['lastName']!,
          googleIdToken: result['idToken']!,
          deviceId: result['deviceId']!,
          email: result['email']!,
          firebaseUserId: result['firebaseUserId']!,
          pushToken: result['pushToken']!,
          onSuccess: onSuccess,
          onError: onError,
        ),
      );
    } catch (e) {
      onError('Failed to sign in with Google: ${e.toString()}');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleAuthService.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  /// Check if user is signed in
  bool get isSignedIn => _googleAuthService.isSignedIn;
}