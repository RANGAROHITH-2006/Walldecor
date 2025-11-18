import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/feedback_model.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  static const String _baseUrl = 'http://172.168.17.2:13024';

  Future<bool> submitFeedback({
    required bool option1,
    required bool option2,
    required bool option3,
    required bool option4,
    required String comment,
  }) async {
    try {
      // Get device information
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';
      String deviceVersion = '';
      String deviceName = '';
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceVersion = androidInfo.version.release;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
        deviceVersion = iosInfo.systemVersion;
        deviceName = '${iosInfo.name} ${iosInfo.model}';
      }

      // Use default values for app version and location since packages are not available
      String appVersion = '1.0.0';
      String buildNumber = '1';
      String location = 'unknown';

      // Get auth token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token == null) {
        if (kDebugMode) print('No auth token found for feedback submission');
        return false;
      }

      // Create feedback request
      final feedbackRequest = FeedbackRequest(
        appVersion: appVersion,
        buildNumber: buildNumber,
        location: location,
        deviceId: deviceId,
        deviceVersion: deviceVersion,
        deviceName: deviceName,
        option1: option1 ? 'true' : 'false',
        option2: option2 ? 'true' : 'false',
        option3: option3 ? 'true' : 'false',
        option4: option4 ? 'true' : 'false',
        comment: comment,
      );

      if (kDebugMode) print('Submitting feedback: ${feedbackRequest.toJson()}');

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(feedbackRequest.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) print('Feedback submitted successfully: ${response.body}');
        return true;
      } else {
        if (kDebugMode) {
          print('Feedback submission failed: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error submitting feedback: $e');
      return false;
    }
  }
}