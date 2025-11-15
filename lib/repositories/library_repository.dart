// repository/library_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/all_library_model.dart';

class LibraryRepository {
  final String baseUrl = "http://172.168.17.2:13024";

 Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  Future<Map<String, dynamic>> createLibrary(
    String inputToken, {
    required String libraryName,
    required String id,
    required Map<String, dynamic> urls,
    required Map<String, dynamic> user,
  }) async {
    final url = Uri.parse("$baseUrl/library");
    final token = await _getSavedToken();
    
    final requestBody = {
      "libraryName": libraryName,
      "id": id,
      "urls": urls,
      "user": user,
    };
    
    print("Creating library with data: ${jsonEncode(requestBody)}");
    print("Using token: ${token?.substring(0, 10)}...");
    
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "x-auth-token": token ?? "",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
       print("Library created successfully");
       return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed: ${response.statusCode} → ${response.body}");
    }
  }


  Future<List<AllLibraryModel>> fetchLibraryData() async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
    
    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }
    
    final url = Uri.parse('$baseUrl/library');
    print('🔥 Fetching from URL: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
      );

      print('🔥 Response status: ${response.statusCode}');
      print('🔥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          return data.map((e) => AllLibraryModel.fromJson(e)).toList();
        } else {
          throw Exception('Expected List but got ${data.runtimeType}');
        }
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔥 Error fetching library data: $e');
      throw Exception('Failed to fetch library data: $e');
    }
  }
}
