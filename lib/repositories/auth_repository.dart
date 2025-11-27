// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

class AuthRepository {
  static const String _baseUrl = 'http://172.168.17.2:13024';
  static const String _guestIdKey = 'guest_id';
  static const String _authTokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type'; 
  static const String _userDataKey = 'user_data';
  
  final http.Client _httpClient;
  final DeviceInfoPlugin _deviceInfo;
  final Uuid _uuid;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    http.Client? httpClient,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _httpClient = httpClient ?? http.Client(),
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _uuid = uuid ?? const Uuid(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Check if any token exists in SharedPreferences
  Future<Map<String, String>?> getStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guestId = prefs.getString(_guestIdKey);
      final authToken = prefs.getString(_authTokenKey);
      final userType = prefs.getString(_userTypeKey);
      
      if (guestId != null && authToken != null && userType != null) {
        return {
          'guestId': guestId,
          'authToken': authToken,
          'userType': userType,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get stored tokens: $e');
    }
  }

  /// Save authentication data to SharedPreferences
  Future<void> saveAuthData({
    required String guestId,
    required String authToken,
    required String userType,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_guestIdKey, guestId);
      await prefs.setString(_authTokenKey, authToken);
      await prefs.setString(_userTypeKey, userType);
      
      if (userData != null) {
        await prefs.setString(_userDataKey, jsonEncode(userData));
      }
    } catch (e) {
      throw Exception('Failed to save auth data: $e');
    }
  }

  /// Get unique device ID
  Future<String> getDeviceId() async {
    return await _getDeviceId();
  }

  /// Get unique device ID (private method)
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

  /// Create guest account via API
  Future<Map<String, String>> createGuestAccount() async {
    try {
      print('🚀 Starting guest account creation...');
      
      final deviceId = await _getDeviceId();
      final pushToken = 'guest_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';

      print('Creating guest account with:');
      print('Device ID: $deviceId');
      print('Push Token: $pushToken');

      final requestBody = {
        'firstName': '',
        'lastName': '',
        'pushToken': pushToken,
        'deviceId': deviceId,
      };
      
      print('Request body: ${jsonEncode(requestBody)}');
      print('Making API request to: $_baseUrl/auth/guest');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/guest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          print('❌ Request timed out after 25 seconds');
          throw Exception('Request timed out');
        },
      );

      print('✅ Response received!');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('🎉 SUCCESS: Guest account created successfully!');
        final data = jsonDecode(response.body);
        final guestId = data['_id'];
        final xAuthToken = response.headers['x-auth-token'];

        print('x-auth-token: $xAuthToken');
        print('Guest ID: $guestId');
        if (guestId == null) {
          throw Exception('Guest ID not found in API response');
        }
      
        if (xAuthToken == null) {
          throw Exception('x-auth-token not found in response headers');
        }
        
        // Save authentication data
        await saveAuthData(
          guestId: guestId,
          authToken: xAuthToken,
          userType: 'guest',
        );
        print('✅ Authentication data saved successfully!');

        return {
          'guestId': guestId,
          'authToken': xAuthToken,
        };
      } else {
        print('❌ Guest account creation failed!');
        print('Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception(
          'Failed to create guest account. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on TimeoutException catch (e) {
      throw Exception('Network timeout: $e Please check your internet connection');
    } catch (e) {
      print('❌ Unexpected error creating guest account: $e');
      print('Error type: ${e.runtimeType}');
      
      // Check if it's a socket exception (network connectivity issue)
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection')) {
        throw Exception('Network connection error: Please check your internet connection and try again');
      }
      
      throw Exception('Failed to create guest account: $e');
    }
  }

  /// Login with Google via API
  Future<Map<String, String>> loginWithGoogle({
    required String firstName,
    required String lastName,
    required String email,
    required String firebaseUserId,
    required String pushToken,
    required String deviceId,
    required String idToken,
    String? profileImageUrl,
  }) async {
    try {
      print('Logging in with Google:');
      print('Email: $email');
      print('Firebase User ID: $firebaseUserId');
     

      // Get guest user ID from local storage for data transfer
      final prefs = await SharedPreferences.getInstance();
      final guestUserId = prefs.getString(_guestIdKey);
       print('guestUserId: $guestUserId');
      final requestBody = {
        'email': email,
        'firebaseUserId': firebaseUserId,
        'pushToken': pushToken,
        'deviceId': deviceId,
        'userId': guestUserId ?? '',
      };
      
      // If guest user ID exists, include it in the request body for data transfer
      if (guestUserId != null && guestUserId.isNotEmpty) {
        requestBody['guestUserId'] = guestUserId;
        print('Including guest user ID for data transfer: $guestUserId');
      }

      print('Request body: ${jsonEncode(requestBody)}');
      print('Making API request to: $_baseUrl/auth/loginWithGoogle');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/loginWithGoogle'),
        headers: {
          'Content-Type': 'application/json',
          'google-id-token': idToken,
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Google login request timed out after 30 seconds');
          throw Exception('Request timed out');
        },
      );

      print('✅ Google login response received!');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('🎉 SUCCESS: Google login successful!');
        
        final data = jsonDecode(response.body);
        final userId = data['_id'] ?? data['userId'];
        final authToken = response.headers['x-auth-token'] ?? data['token'];

        print('Extracted data:');
        print('User ID: $userId');
        print('X-Auth-token: $authToken');

        if (userId == null) {
          throw Exception('User ID not found in API response');
        }

        if (authToken == null) {
          throw Exception('X-Auth-token not found in API response');
        }

        print('💾 Saving Google authentication data...');

        // Save authentication data
        await saveAuthData(
          guestId: userId,
          authToken: authToken,
          userType: 'google',
          userData: {
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'firebaseUserId': firebaseUserId,
            'profileImageUrl': profileImageUrl ?? '',
          },
        );

        print('✅ Google authentication data saved successfully!');
        print('🎯 Google login completed successfully!');

        return {
          'userId': userId,
          'authToken': authToken,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
        };
      } else {
        throw Exception(
          'Failed to login with Google. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error logging in with Google: $e');
      throw Exception('Failed to login with Google: $e');
    }
  }

  /// Login with Apple via API
  Future<Map<String, String>> loginWithApple({
    required String firstName,
    required String lastName,
    required String email,
    required String firebaseUserId,
    required String pushToken,
    required String deviceId,
    required String idToken,
    String? appleUserId,
  }) async {
    try {
      print('Logging in with Apple:');
      print('Email: $email');
      print('Firebase User ID: $firebaseUserId');

      // Get guest user ID from local storage for data transfer
      final prefs = await SharedPreferences.getInstance();
      final guestUserId = prefs.getString(_guestIdKey);
      
      final requestBody = {
        'email': email,
        'firebaseUserId': firebaseUserId,
        'pushToken': pushToken,
        'deviceId': deviceId,
        'userId': guestUserId ?? '',
      };
      
      // If guest user ID exists, include it in the request body for data transfer
      if (guestUserId != null && guestUserId.isNotEmpty) {
        requestBody['guestUserId'] = guestUserId;
        print('Including guest user ID for data transfer: $guestUserId');
      }

      print('Request body: ${jsonEncode(requestBody)}');
      print('Making API request to: $_baseUrl/auth/loginWithApple');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/loginWithApple'),
        headers: {
          'Content-Type': 'application/json',
          'apple-id-token': idToken,
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Apple login request timed out after 30 seconds');
          throw Exception('Request timed out');
        },
      );

      print('✅ Apple login response received!');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('🎉 SUCCESS: Apple login successful!');
        
        final data = jsonDecode(response.body);
        final userId = data['_id'] ?? data['userId'];
        final authToken = response.headers['x-auth-token'] ?? data['token'];

        print('Extracted data:');
        print('User ID: $userId');
        print('X-Auth-token: $authToken');

        if (userId == null) {
          throw Exception('User ID not found in API response');
        }

        if (authToken == null) {
          throw Exception('X-Auth-token not found in API response');
        }

        print('💾 Saving Apple authentication data...');

        // Save authentication data
        await saveAuthData(
          guestId: userId,
          authToken: authToken,
          userType: 'apple',
          userData: {
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'firebaseUserId': firebaseUserId,
            'appleUserId': appleUserId,
          },
        );

        print('✅ Apple authentication data saved successfully!');
        print('🎯 Apple login completed successfully!');

        return {
          'userId': userId,
          'authToken': authToken,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
        };
      } else {
        throw Exception(
          'Failed to login with Apple. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error logging in with Apple: $e');
      throw Exception('Failed to login with Apple: $e');
    }
  }

  /// Logout via API (calls logout endpoint to remove push token)
  Future<void> logout() async {
    try {
      print('🚀 Starting logout process...');
      
      // Get stored tokens
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(_authTokenKey);
      
      if (authToken != null) {
        // Get FCM token to send to logout API
        final pushToken = await _getFCMToken();
        
        print('Logout request with push token: $pushToken');
        
        final requestBody = {
          'pushToken': pushToken,
        };
        
        print('Request body: ${jsonEncode(requestBody)}');
        print('Making logout API request to: $_baseUrl/auth/logout');

        final response = await _httpClient.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': authToken,
          },
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 25),
          onTimeout: () {
            print('❌ Logout request timed out after 25 seconds');
            throw Exception('Request timed out');
          },
        );

        print('✅ Logout API response received!');
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode != 200) {
          print('⚠️ Logout API failed, but continuing with local cleanup');
          print('Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
      
      // Always remove local data regardless of API call result
      await removeAuthData();
      print('✅ Logout completed successfully!');
      
    } catch (e) {
      print('❌ Error during logout API call: $e');
      // Even if API call fails, remove local data
      await removeAuthData();
      print('✅ Local data cleared after API error');
      throw Exception('Logout completed with warnings: $e');
    }
  }

  /// Get current auth token from SharedPreferences
  Future<String?> getCurrentAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get current user ID from SharedPreferences
  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_guestIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in (either as guest or with Google/Apple)
  Future<bool> isLoggedIn() async {
    final token = await getCurrentAuthToken();
    final userId = await getCurrentUserId();
    return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
  }

  /// Get FCM token for logout
  Future<String> _getFCMToken() async {
    try {
      // Import firebase_messaging
      final firebaseMessaging = FirebaseMessaging.instance;
      final token = await firebaseMessaging.getToken();
      return token ?? 'no_token_available';
    } catch (e) {
      print('Failed to get FCM token: $e');
      return 'token_error';
    }
  }

  /// Remove all authentication data (for logout functionality)
  Future<void> removeAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userTypeKey);
      await prefs.remove(_userDataKey);
    } catch (e) {
      throw Exception('Failed to remove auth data: $e');
    }
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        return jsonDecode(userDataJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current user type from SharedPreferences
  Future<String?> getCurrentUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTypeKey);
    } catch (e) {
      return null;
    }
  }

  /// Get stored guest user ID from SharedPreferences
  Future<String?> getGuestUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_guestIdKey);
    } catch (e) {
      print('Error getting guest user ID: $e');
      return null;
    }
  }

  /// Check if current user is guest
  Future<bool> isGuestUser() async {
    try {
      final userType = await getCurrentUserType();
      return userType == 'guest';
    } catch (e) {
      return false;
    }
  }

  /// Check if current user is authenticated (Google or Apple)
  Future<bool> isAuthenticatedUser() async {
    try {
      final userType = await getCurrentUserType();
      return userType == 'google' || userType == 'apple';
    } catch (e) {
      return false;
    }
  }

  /// Get profile image URL from stored user data
  Future<String?> getProfileImageUrl() async {
    try {
      final userData = await getStoredUserData();
      if (userData != null && userData['profileImageUrl'] != null) {
        final profileUrl = userData['profileImageUrl'] as String;
        return profileUrl.isNotEmpty ? profileUrl : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update profile image URL in stored user data
  Future<void> updateProfileImageUrl(String? profileImageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        Map<String, dynamic> userData = jsonDecode(userDataJson);
        userData['profileImageUrl'] = profileImageUrl ?? '';
        await prefs.setString(_userDataKey, jsonEncode(userData));
      }
    } catch (e) {
      print('Error updating profile image URL: $e');
    }
  }

  /// Delete user account via API
  Future<String> deleteAccount() async {
    try {
      print('🚀 Starting account deletion process...');
      
      // Get stored tokens
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(_authTokenKey);
      
      if (authToken == null) {
        throw Exception('No auth token found');
      }
      
      print('Making delete account API request to: $_baseUrl/user');
      
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Delete account request timed out after 30 seconds');
          throw Exception('Request timed out');
        },
      );
      
      print('✅ Delete account API response received!');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('🎉 SUCCESS: Account deleted successfully!');
        
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Account deleted successfully';
        
        // Remove local data after successful deletion
        await removeAuthData();
        print('✅ Local data cleared after account deletion');
        
        return message;
      } else {
        print('❌ Account deletion failed!');
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? 'Failed to delete account';
        throw Exception(errorMessage);
      }
    } on TimeoutException catch (e) {
      print('❌ Network timeout error: $e');
      throw Exception('Network timeout: Please check your internet connection');
    } catch (e) {
      print('❌ Unexpected error deleting account: $e');
      print('Error type: ${e.runtimeType}');
      
      // Check if it's a socket exception (network connectivity issue)
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection')) {
        throw Exception('Network connection error: Please check your internet connection and try again');
      }
      
      throw Exception('Failed to delete account: $e');
    }
  }

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
      final String? userIdToken = await user.getIdToken();
      final String idToken = userIdToken ?? '';
      if (idToken.isEmpty) {
        throw Exception('Failed to get ID token from Firebase');
      }

      // Get device ID
      final String deviceId = await _getDeviceId();
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
      final String deviceId = await _getDeviceId();
      
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

  /// Sign out from Google and Firebase
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Check if user is currently signed in to Firebase
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