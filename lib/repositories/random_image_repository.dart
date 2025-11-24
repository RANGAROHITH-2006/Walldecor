// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/random_image_model.dart';

class RandomImageRepository {
  final String baseUrl = 'http://172.168.17.2:13024';

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<RandomImageModel>> fetchRandomImages(String categoryId) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }

    final requestBody = {
      "type": "CATEGORY",
      "categoryId": categoryId
    };

    print('🔥 Random Image API Request Body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/unsplashImage/randomImage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode(requestBody),
    );

    print('🔥 Random Image API Response Status: ${response.statusCode}');
    print('🔥 Random Image API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RandomImageModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch random images: ${response.statusCode} → ${response.body}');
    }
  }
}