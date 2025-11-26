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

  Future<List<CategorydetailesModel>> fetchCarouselWallpapers(String categorySlug, {int limit = 4}) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }

    // First get all categories to find the wallpapers category ID
    final categoriesResponse = await http.get(Uri.parse('$baseUrl/unsplashImage/category'),
     headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, 
        },
    );

    if (categoriesResponse.statusCode != 200) {
      throw Exception('Failed to fetch categories');
    }

    final List categoriesData = jsonDecode(categoriesResponse.body);
    final categories = categoriesData.map((e) => CategoryModel.fromJson(e)).toList();
    
    // Find the wallpapers category
    final wallpapersCategory = categories.firstWhere(
      (category) => category.slug.toLowerCase().contains(categorySlug.toLowerCase()) || 
                   category.title.toLowerCase().contains(categorySlug.toLowerCase()),
      orElse: () => throw Exception('Wallpapers category not found'),
    );

    // Now fetch wallpapers from that category
    final response = await http.get(Uri.parse('$baseUrl/unsplashImage/category/${wallpapersCategory.id}'),
     headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final wallpapers = data.map((e) => CategorydetailesModel.fromJson(e)).toList();
      // Return only the first 'limit' wallpapers
      return wallpapers.take(limit).toList();
    } else {
        throw Exception('Failed to fetch wallpapers: ${response.statusCode} → ${response.body}');
    }
  }

  Future<List<CategorydetailesModel>> fetchCategoryDetailedDataWithPagination(
    String id, {
    int page = 1,
    int limit = 15,
  }) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }

    final url = '$baseUrl/unsplashImage/category/$id?page=$page&limit=$limit';
    print('📍 Fetching category details from: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token, 
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategorydetailesModel.fromJson(e)).toList();
    } else {
      print("Category pagination API error: ${response.statusCode} → ${response.body}");
      throw Exception('Failed to fetch paginated category data: ${response.statusCode} → ${response.body}');
    }
  }
}
