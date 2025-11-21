// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/favorite_model.dart';

class FavoriteRepository {
  final String baseUrl = "http://172.168.17.2:13024";

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Add image to favorites
  Future<Map<String, dynamic>> addToFavorites({
    required String id,
    required Map<String, dynamic> urls,
    required Map<String, dynamic> user,
  }) async {
    final url = Uri.parse("$baseUrl/user/favorite");
    final token = await _getSavedToken();

    final requestBody = {
      "id": id,
      "urls": urls,
      "user": user,
    };

    print("🔥 Adding to favorites with data: ${jsonEncode(requestBody)}");
    print("🔥 Using token: ${token?.substring(0, 10)}...");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token ?? "",
        },
        body: jsonEncode(requestBody),
      );

      print("🔥 Favorite response status: ${response.statusCode}");
      print("🔥 Favorite response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("🔥 Image added to favorites successfully");
        
        if (response.body.isEmpty) {
          return {"success": true, "message": "Image added to favorites successfully"};
        }

        try {
          final responseData = jsonDecode(response.body);
          // Check if the API returns a specific message about already being in favorites
          if (responseData is Map && responseData.containsKey('message')) {
            return {"success": true, "message": responseData['message']};
          }
          return responseData;
        } catch (jsonError) {
          print("🔥 JSON decode error: $jsonError");
          return {"success": true, "message": "Image added to favorites successfully"};
        }
      } else {
        print("🔥 Favorite API Error: ${response.statusCode} - ${response.body}");
        
        // Check if it's a 400 error indicating already exists
        if (response.statusCode == 400) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData is Map && errorData.containsKey('message')) {
              return {"success": false, "message": errorData['message']};
            }
          } catch (e) {
            print("🔥 Error parsing 400 response: $e");
          }
          return {"success": false, "message": "Image is already in favorites"};
        }
        
        throw Exception("Failed to add to favorites: ${response.statusCode} → ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception adding to favorites: $e");
      throw Exception("Failed to add to favorites: $e");
    }
  }

  // Fetch user favorites
  Future<List<FavoriteImageModel>> fetchFavorites() async {
    final token = await _getSavedToken();
    print('🔥 Fetching favorites with token: ${token?.substring(0, 10)}...');

    if (token == null || token.isEmpty) {
      throw Exception('Auth token not found in SharedPreferences');
    }

    // Try multiple possible endpoints
    final endpoints = [
      '$baseUrl/user',
    ];
    
    for (String endpoint in endpoints) {
      final url = Uri.parse(endpoint);
      print('🔥 Trying endpoint for favorites: $url');

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
        );

        print('🔥 Favorites response status: ${response.statusCode}');
        print('🔥 Favorites response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('🔥 Raw favorites response type: ${data.runtimeType}');
          print('🔥 Response keys: ${data is Map ? data.keys.toList() : 'N/A'}');

          // Handle different response formats
          if (data is List) {
            // Direct array response
            print('🔥 Processing favorites as direct List');
            return data.map((e) => FavoriteImageModel.fromJson(e)).toList();
          } else if (data is Map<String, dynamic>) {
            // Object response - check for common patterns
            print('🔥 Processing favorites as Map response');
            
            if (data.containsKey('favoriteImage') && data['favoriteImage'] is List) {
              // Response like: { "favoriteImage": [...], "success": true }
              print('🔥 Found favoriteImage array in response');
              final List favoritesList = data['favoriteImage'];
              return favoritesList.map((e) => FavoriteImageModel.fromJson(e)).toList();
            } else if (data.containsKey('favoriteImages') && data['favoriteImages'] is List) {
              // Response like: { "favoriteImages": [...], "success": true }
              print('🔥 Found favoriteImages array in response');
              final List favoritesList = data['favoriteImages'];
              return favoritesList.map((e) => FavoriteImageModel.fromJson(e)).toList();
            } else if (data.containsKey('favorites') && data['favorites'] is List) {
              // Response like: { "favorites": [...], "total": 5 }
              print('🔥 Found favorites array in response');
              final List favoritesList = data['favorites'];
              return favoritesList.map((e) => FavoriteImageModel.fromJson(e)).toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              // Response like: { "data": [...], "success": true }
              print('🔥 Found data array in favorites response');
              final List favoritesList = data['data'];
              return favoritesList.map((e) => FavoriteImageModel.fromJson(e)).toList();
            } else if (data.containsKey('result') && data['result'] is List) {
              // Response like: { "result": [...], "success": true }
              print('🔥 Found result array in favorites response');
              final List favoritesList = data['result'];
              return favoritesList.map((e) => FavoriteImageModel.fromJson(e)).toList();
            } else {
              // Check if user data contains favorites
              if (data.containsKey('favoriteImage')) {
                final favoriteImages = data['favoriteImage'];
                if (favoriteImages is List) {
                  print('🔥 Found favoriteImage in user data');
                  return favoriteImages.map((e) => FavoriteImageModel.fromJson(e)).toList();
                }
              }
              
              print('🔥 No recognized favorite array found. Available keys: ${data.keys.toList()}');
              return []; // Return empty list if no favorites
            }
          } else {
            print('🔥 Unexpected response type: ${data.runtimeType}');
            continue; // Try next endpoint
          }
        } else if (response.statusCode == 404) {
          // No favorites found
          print('🔥 No favorites found (404) on endpoint: $endpoint');
          continue; // Try next endpoint
        } else {
          print('🔥 API Error on $endpoint: ${response.statusCode} - ${response.body}');
          continue; // Try next endpoint
        }
      } catch (e) {
        print('🔥 Error fetching from $endpoint: $e');
        continue; // Try next endpoint
      }
    }
    
    // If we get here, all endpoints failed
    print('🔥 All endpoints failed, returning empty favorites list');
    return [];
  }

  // Remove from favorites (optional feature)
  Future<Map<String, dynamic>> removeFromFavorites(String imageId) async {
    final token = await _getSavedToken();
    final url = Uri.parse("$baseUrl/user/favorite/$imageId");

    print("🔥 Removing from favorites: $imageId");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token ?? "",
        },
      );

      print("🔥 Remove favorite response status: ${response.statusCode}");
      print("🔥 Remove favorite response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("🔥 Image removed from favorites successfully");
        
        if (response.body.isEmpty) {
          return {"success": true, "message": "Image removed from favorites successfully"};
        }

        try {
          return jsonDecode(response.body);
        } catch (jsonError) {
          print("🔥 JSON decode error: $jsonError");
          return {"success": true, "message": "Image removed from favorites successfully"};
        }
      } else {
        print("🔥 Remove favorite API Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to remove from favorites: ${response.statusCode} → ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception removing from favorites: $e");
      throw Exception("Failed to remove from favorites: $e");
    }
  }
}