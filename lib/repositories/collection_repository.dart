import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/collection_model.dart';
import 'package:walldecor/models/collectiondetailes_model.dart';

class CollectionRepository {
  final String baseUrl = 'http://172.168.17.2:13024'; 
 

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<CollectionModel>> fetchCollectionData() async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
      if (token == null || token.isEmpty) {
        throw Exception('Guest token not found in SharedPreferences');
      }
    final response = await http.get(Uri.parse('$baseUrl/unsplashImage/collection'),
     headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token, 
        },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CollectionModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }


   Future<List<CollectiondetailesModel>> fetchCollectionDetailedData(String id) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
      if (token == null || token.isEmpty) {
        throw Exception('Guest token not found in SharedPreferences');
      }

      print('$baseUrl/unsplashImage/collection/$id');
    final response = await http.get(Uri.parse('$baseUrl/unsplashImage/collection/$id'),
     headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CollectiondetailesModel.fromJson(e)).toList();
    } else {
      print("i am actual got error here ${response.statusCode} → ${response.body}");
        throw Exception('Failed to fetch data: ${response.statusCode} → ${response.body}');
    }
  }

  Future<List<CollectiondetailesModel>> fetchCollectionDetailedDataWithPagination(
    String id, {
    int page = 1,
    int limit = 15,
  }) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }

    final url = '$baseUrl/unsplashImage/collection/$id?page=$page&limit=$limit';
    print('📍 Fetching collection details from: $url');
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token, 
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CollectiondetailesModel.fromJson(e)).toList();
    } else {
      print("Pagination API error: ${response.statusCode} → ${response.body}");
      throw Exception('Failed to fetch paginated data: ${response.statusCode} → ${response.body}');
    }
  }
}
