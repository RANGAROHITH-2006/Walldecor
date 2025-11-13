// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/category_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';


class CategoryRepository {
  final String baseUrl = 'http://172.168.17.2:13024'; 
 

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<CategoryModel>> fetchCategoryData() async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
      if (token == null || token.isEmpty) {
        throw Exception('Guest token not found in SharedPreferences');
      }
    final response = await http.get(Uri.parse('$baseUrl/unsplashImage/category'),
     headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, 
        },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }


   Future<List<CategorydetailesModel>> fetchCategoryDetailedData(id) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
      if (token == null || token.isEmpty) {
        throw Exception('Guest token not found in SharedPreferences');
      }
    final response = await http.get(Uri.parse('$baseUrl/unsplashImage/category/$id'),
     headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategorydetailesModel.fromJson(e)).toList();
    } else {
        throw Exception('Failed to fetch data: ${response.statusCode} → ${response.body}');
    }
  }
}
