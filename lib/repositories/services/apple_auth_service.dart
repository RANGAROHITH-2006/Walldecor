import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AppleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check if Apple Sign In is available (iOS 13+ or macOS 10.15+)
  Future<bool> isAppleSignInAvailable() async {
    return await SignInWithApple.isAvailable();
  }

  /// Sign in with Apple and get required data for API
  Future<Map<String, String>?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      if (!await isAppleSignInAvailable()) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Request Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create a Firebase credential from the Apple credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final User? user = userCredential.user;
      
      if (user == null) {
        throw Exception('Failed to get user from Firebase');
      }

      // Get Firebase ID token
      final String? firebaseIdToken = await user.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to get ID token from Firebase');
      }

      // Get device ID
      final String deviceId = await getDeviceId();
      
      // Get FCM push token
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      final String pushToken = fcmToken ?? '';

      // Extract user information
      String firstName = '';
      String lastName = '';
      String email = '';

      // Get email from user (might be null if user chose to hide it)
      email = user.email ?? '';

      // Get name from Apple credential (only available on first sign-in)
      if (credential.givenName != null || credential.familyName != null) {
        firstName = credential.givenName ?? '';
        lastName = credential.familyName ?? '';
      } else {
        // If name not available from Apple credential, try from Firebase user
        final displayName = user.displayName ?? '';
        if (displayName.isNotEmpty) {
          final nameParts = displayName.split(' ');
          firstName = nameParts.isNotEmpty ? nameParts.first : '';
          lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
        }
      }

      // If email is hidden by Apple, use a placeholder
      if (email.isEmpty) {
        email = '${user.uid}@privaterelay.appleid.com';
      }

      return {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'firebaseUserId': user.uid,
        'idToken': firebaseIdToken,
        'deviceId': deviceId,
        'pushToken': pushToken,
        'appleUserId': credential.userIdentifier ?? user.uid,
      };
    } catch (e) {
      print('Error signing in with Apple: $e');
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  /// Get unique device ID
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final deviceId = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.device}';
        return deviceId.replaceAll(' ', '_').toLowerCase();
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        if (iosInfo.identifierForVendor != null) {
          return iosInfo.identifierForVendor!;
        }
        return '${iosInfo.name}_${iosInfo.model}'.replaceAll(' ', '_').toLowerCase();
      } else {
        return 'unknown_device';
      }
    } catch (e) {
      return 'fallback_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Sign out from Apple and Firebase
  // Future<void> signOut() async {
  //   try {
  //     await _firebaseAuth.signOut();
  //   } catch (e) {
  //     print('Error signing out: $e');
  //     throw Exception('Failed to sign out: $e');
  //   }
  // }

  /// Check if user is currently signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Refresh Firebase ID token
  Future<String?> refreshFirebaseToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true); // Force refresh
        return token;
      }
      return null;
    } catch (e) {
      print('Error refreshing Firebase token: $e');
      return null;
    }
  }

  /// Check if Firebase user session is valid
  Future<bool> isFirebaseSessionValid() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Try to get a fresh token to verify session
        final token = await user.getIdToken(false);
        return token != null && token.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Firebase session validation failed: $e');
      return false;
    }
  }
}