import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _guestIdKey = 'guest_id';
  static const String _authTokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  
  /// Get current auth token from SharedPreferences
  static Future<String?> getCurrentAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_authTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get current user ID from SharedPreferences
  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_guestIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Get user type (guest or google)
  static Future<String?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTypeKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in (either as guest or with Google)
  static Future<bool> isLoggedIn() async {
    final token = await getCurrentAuthToken();
    final userId = await getCurrentUserId();
    return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
  }

  /// Check if user is logged in as guest
  static Future<bool> isGuestUser() async {
    final userType = await getUserType();
    return userType == 'guest';
  }

  /// Check if user is logged in with Google
  static Future<bool> isGoogleUser() async {
    final userType = await getUserType();
    return userType == 'google';
  }
}