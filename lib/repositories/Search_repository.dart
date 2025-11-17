// repository/library_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepository {
  final String baseUrl = "http://172.168.17.2:13024";

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> SearchLibrary( {
    required String text
  }) async {
    final url = Uri.parse("$baseUrl/unsplashImage/search");
    final token = await _getSavedToken();

    final requestBody = {"text": text};

    print("Creating library with data: ${jsonEncode(requestBody)}");
    print("Using token: ${token?.substring(0, 10)}...");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "$token"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Library created successfully");
      final responseData = jsonDecode(response.body);
      if (responseData is List) {
        return {"results": responseData};
      } else if (responseData is Map<String, dynamic>) {
        return responseData;
      } else {
        throw Exception("Unexpected response format: ${responseData.runtimeType}");
      }
    } else {
      throw Exception("Failed: ${response.statusCode} → ${response.body}");
    }
  }
}
