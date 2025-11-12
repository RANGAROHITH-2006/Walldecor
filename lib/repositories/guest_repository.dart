import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class GuestRepository {
  static const String _baseUrl = 'http://172.168.17.2:13024';
  static const String _guestTokenKey = 'guest_token';

  final http.Client _httpClient;
  final DeviceInfoPlugin _deviceInfo;
  final Uuid _uuid;

  GuestRepository({
    http.Client? httpClient,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
  }) : _httpClient = httpClient ?? http.Client(),
       _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _uuid = uuid ?? const Uuid();

  /// Check if guest token exists in SharedPreferences
  Future<String?> getStoredGuestToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_guestTokenKey);
    } catch (e) {
      throw Exception('Failed to get stored guest token: $e');
    }
  }

  /// Save guest token to SharedPreferences
  Future<void> saveGuestToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_guestTokenKey, token);
    } catch (e) {
      throw Exception('Failed to save guest token: $e');
    }
  }

  /// Get unique device ID
  Future<String> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Create a composite device ID from available properties
        final deviceId =
            '${androidInfo.brand}_${androidInfo.model}_${androidInfo.device}';
        return deviceId.replaceAll(' ', '_').toLowerCase();
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        if (iosInfo.identifierForVendor != null) {
          return iosInfo.identifierForVendor!;
        }
        return '${iosInfo.name}_${iosInfo.model}'
            .replaceAll(' ', '_')
            .toLowerCase();
      } else {
        return 'unknown_device';
      }
    } catch (e) {
      // Provide a fallback device ID if device info fails
      return 'fallback_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Create guest account via API
  Future<String> createGuestAccount() async {
    try {
      final deviceId = await _getDeviceId();
      final pushToken =
          'guest_${_uuid.v4().replaceAll('-', '').substring(0, 16)}';

      print('Creating guest account with:');
      print('Device ID: $deviceId');
      print('Push Token: $pushToken');

      final requestBody = {
        'firstName': 'Guest',
        'lastName': 'User',
        'pushToken': pushToken,
        'deviceId': deviceId,
      };

      print('Request body: ${jsonEncode(requestBody)}');

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth/guest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final guestId = data['_id'];
        final xAuthToken = response.headers['x-auth-token'];

        if (guestId == null) {
          throw Exception('Guest ID not found in API response');
        }
      
        if (xAuthToken == null) {
          throw Exception('x_auth_token not found in response headers');
        }

        print('xAuthToken: $xAuthToken');

        // Save this X_auth_token and guestId securely 
        await saveGuestToken(xAuthToken);
        await saveGuestToken(guestId);
        return guestId;
      } else {
        throw Exception(
          'Failed to create guest account. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating guest account: $e');
      throw Exception('Failed to create guest account: $e');
    }
  }

  /// Remove guest token (for logout functionality)
  Future<void> removeGuestToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestTokenKey);
    } catch (e) {
      throw Exception('Failed to remove guest token: $e');
    }
  }
}
