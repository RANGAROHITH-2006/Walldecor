import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const String _guestTokenKey = 'guest_token';
  
  /// Get current guest token from SharedPreferences
  static Future<String?> getCurrentGuestToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_guestTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in as guest
  static Future<bool> isGuestLoggedIn() async {
    final token = await getCurrentGuestToken();
    return token != null && token.isNotEmpty;
  }
}