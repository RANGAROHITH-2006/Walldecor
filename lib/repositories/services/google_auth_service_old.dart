// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Add required scopes for Google Sign-In
    scopes: [
      'email',
      'profile',
    ],
  );
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Sign in with Google and get required data for API
  Future<Map<String, String>?> signInWithGoogle() async {
    try {
      print('🚀 Starting Google Sign-In process...');
      print('🔧 Google Sign-In configuration check...');
      
      // First check if Google Play Services is available
      print('📱 Checking Google Play Services availability...');
      
      // Try a simple operation first to check configuration
      try {
        final bool isSignedIn = await _googleSignIn.isSignedIn();
        print('✅ Google Sign-In SDK initialized successfully (currently signed in: $isSignedIn)');
      } catch (initError) {
        print('❌ Google Sign-In initialization failed: $initError');
        
        if (initError.toString().contains('channel-error') || 
            initError.toString().contains('SIGN_IN_REQUIRED') ||
            initError.toString().contains('OAuth')) {
        
          throw Exception('Google Sign-In not configured in Firebase Console. oauth_client array is empty. Please enable Google Sign-In provider first.');
        }
        
        throw Exception('Google Sign-In initialization failed: $initError');
      }

      // If we reach here, try the actual sign-in
      print('📱 Attempting Google account selection...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ User canceled Google Sign-In');
        return null;
      }

      print('✅ Google user obtained: ${googleUser.email}');

      // Obtain the auth details from the request
      print('📱 Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if tokens are available
      if (googleAuth.accessToken == null) {
        print('❌ Access token is null');
        throw Exception('Failed to get Google access token');
      }
      
      if (googleAuth.idToken == null) {
        print('❌ ID token is null');
        throw Exception('Failed to get Google ID token');
      }

      print('✅ Google auth tokens obtained successfully');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔥 Signing in to Firebase with Google credential...');
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        print('❌ Firebase user is null');
        throw Exception('Failed to get user from Firebase');
      }

      print('✅ Firebase authentication successful: ${user.email}');

      // Get Firebase ID token
      print('🎟️ Getting Firebase ID token...');
      final String? UserIdToken = await user.getIdToken();
      final String idToken = UserIdToken ?? '';
      
      if (idToken.isEmpty) {
        print('❌ Firebase ID token is empty');
        throw Exception('Failed to get ID token from Firebase');
      }

      print('✅ Firebase ID token obtained');

      // Get device ID
      print('📱 Getting device ID...');
      final String deviceId = await _getDeviceId();
      print('✅ Device ID: $deviceId');

      // Get FCM push token
      print('🔔 Getting FCM token...');
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      final String pushToken = fcmToken ?? 'no_fcm_token_available';
      print('✅ FCM Token obtained: ${pushToken.substring(0, 20)}...');

      // Extract user information
      final displayName = user.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      print('✅ User info extracted:');
      print('   - Name: $firstName $lastName');
      print('   - Email: ${user.email}');
      print('   - UID: ${user.uid}');

      return {
        'firstName': firstName,
        'lastName': lastName,
        'email': user.email ?? '',
        'firebaseUserId': user.uid,
        'idToken': idToken,
        'deviceId': deviceId,
        'pushToken': pushToken,
      };
    } on PlatformException catch (e) {
      print('❌ Platform Exception during Google Sign-In: ${e.code} - ${e.message}');
      
      if (e.code == 'channel-error') {
        print('🔧 Channel error detected - this usually means:');
        print('   1. Missing google-services.json file');
        print('   2. SHA-1 fingerprint not added to Firebase');
        print('   3. Google Sign-In not enabled in Firebase Console');
        print('   4. Package name mismatch');
        
        throw Exception('Google Sign-In configuration error. Please check:\n'
            '• google-services.json is in android/app/\n'
            '• SHA-1 fingerprint is added to Firebase Console\n'
            '• Google Sign-In is enabled in Firebase Authentication\n'
            '• Package name matches Firebase project');
      }
      
      throw Exception('Failed to get Google authentication tokens: ${e.message}');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      throw Exception('Firebase authentication failed: ${e.message}');
    } catch (e) {
      print('❌ Exception during Google Sign-In: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Get unique device ID
  Future<String> _getDeviceId() async {
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
  
  /// Debug method to check Google Sign-In configuration
  Future<void> debugGoogleSignInConfiguration() async {
    print('🔍 GOOGLE SIGN-IN CONFIGURATION DEBUG:');
    
    try {
      print('📱 Checking if signed in...');
      final bool isSignedIn = await _googleSignIn.isSignedIn();
      print('✅ isSignedIn check successful: $isSignedIn');
      
      if (isSignedIn) {
        final currentAccount = await _googleSignIn.signInSilently();
        print('   Current account: ${currentAccount?.email ?? "none"}');
      }
      
      print('✅ Google Sign-In appears to be configured correctly');
    } catch (e) {
      print('❌ Configuration check failed: $e');
      
      if (e.toString().contains('channel-error')) {
        print('');
        print('🚨 CHANNEL ERROR = MISSING OAUTH CONFIGURATION');
        print('📋 Current google-services.json status: oauth_client = []');
        print('🔧 This means Google Sign-In provider is NOT enabled in Firebase');
        print('');
        print('✅ SOLUTION:');
        print('   1. Firebase Console → Authentication → Sign-in method');
        print('   2. Enable Google provider');
        print('   3. Add SHA-1 fingerprint');
        print('   4. Download updated google-services.json');
        print('   5. Replace file in android/app/');
        print('   6. flutter clean && flutter run');
      }
    }
  }
}