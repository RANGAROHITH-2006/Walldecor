import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Sign in with Google and get required data for API
  Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to get user from Firebase');
      }

      // Get Firebase ID token
      final String? UserIdToken = await user.getIdToken();
      final String idToken = UserIdToken ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to get ID token from Firebase');
      }

      // Get device ID
      final String deviceId = await getDeviceId();
      // Get FCM push token
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      final String pushToken = fcmToken ?? '';

      // Extract user information
      final displayName = user.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      final profileImageUrl = user.photoURL ?? '';

      return {
        'firstName': firstName,
        'lastName': lastName,
        'email': user.email ?? '',
        'firebaseUserId': user.uid,
        'idToken': idToken,
        'deviceId': deviceId,
        'pushToken': pushToken,
        'profileImageUrl': profileImageUrl,
      };
    } catch (e) {
      print('Error signing in with Google: $e');
      throw Exception('Failed to sign in with Google: $e');
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

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

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