// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/download_model.dart';

class DownloadRepository {
  final String baseUrl = "http://172.168.17.2:13024";

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Helper method to extract actual image ID from prefixed IDs
  String _extractActualImageId(String id) {
    List<String> parts = id.split('_');
    
    if (parts.length >= 2) {
      // Remove first part if it's a known prefix
      if (parts[0] == 'home' || parts[0] == 'col' || parts[0] == 'cat') {
        parts.removeAt(0);
      }
      
      // Remove last part if it looks like a timestamp (13+ digits)
      if (parts.isNotEmpty && parts.last.length >= 13 && RegExp(r'^\d+$').hasMatch(parts.last)) {
        parts.removeLast();
      }
      
      return parts.join('_');
    }
    
    return id; // Return as-is if no pattern matches
  }






  // Check if an image is already downloaded
  Future<bool> isImageDownloaded(String imageId) async {
    try {
      String actualImageId = _extractActualImageId(imageId);
      final existingDownloads = await fetchDownloads();
      return existingDownloads.any((download) {
        String existingActualId = _extractActualImageId(download.id ?? '');
        return existingActualId == actualImageId;
      });
    } catch (e) {
      print("🔥 Error checking if image is downloaded: $e");
      return false; // Assume not downloaded on error
    }
  }








  // Add image to downloads
  Future<Map<String, dynamic>> addToDownloads({
    required String id,
    required Map<String, dynamic> urls,
    required Map<String, dynamic> user,
  }) async {
    // Extract the actual image ID (remove prefixes and timestamp if present)
    String actualImageId = _extractActualImageId(id);
    
    // First check if already exists in downloads using actual image ID
    try {
      final existingDownloads = await fetchDownloads();
      final isAlreadyDownloaded = existingDownloads.any((download) {
        String existingActualId = _extractActualImageId(download.id ?? '');
        return existingActualId == actualImageId;
      });
      
      if (isAlreadyDownloaded) {
        return {"success": false, "message": "Image is already downloaded"};
      }
    } catch (e) {
      print("🔥 Error checking existing downloads: $e");
      // Continue with add operation if check fails
    }

    // Use consistent ID format: actual image ID without timestamp
    final consistentId = actualImageId;

    final url = Uri.parse("$baseUrl/user/download");
    final token = await _getSavedToken();

    final requestBody = {
      "id": consistentId, // Use consistent ID instead of original
      "urls": urls,  // Changed back to "urls" to match API expectation
      "user": user,  // Changed back to "user" to match API expectation
    };

    print("🔥 Adding to downloads with data: ${jsonEncode(requestBody)}");
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

      print("🔥 Download response status: ${response.statusCode}");
      print("🔥 Download response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("🔥 Image added to downloads successfully");
        
        if (response.body.isEmpty) {
          return {"success": true, "message": "Image added to downloads successfully"};
        }

        try {
          return jsonDecode(response.body);
        } catch (jsonError) {
          print("🔥 JSON decode error: $jsonError");
          return {"success": true, "message": "Image added to downloads successfully"};
        }
      } else {
        print("🔥 Download API Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to add to downloads: ${response.statusCode} → ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception adding to downloads: $e");
      throw Exception("Failed to add to downloads: $e");
    }
  }








  // Fetch user downloads
  Future<List<DownloadImageModel>> fetchDownloads() async {
    final token = await _getSavedToken();
    print('🔥 Fetching downloads with token: ${token?.substring(0, 10)}...');

    if (token == null || token.isEmpty) {
      throw Exception('Auth token not found in SharedPreferences');
    }

    // Try multiple possible endpoints
    final endpoints = [
      '$baseUrl/user',
    ];
    
    for (String endpoint in endpoints) {
      final url = Uri.parse(endpoint);
      print('🔥 Trying endpoint: $url');

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
        );

        print('🔥 Downloads response status: ${response.statusCode}');
        print('🔥 Downloads response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('🔥 Raw downloads response type: ${data.runtimeType}');
          print('🔥 Response keys: ${data is Map ? data.keys.toList() : 'N/A'}');

          // Handle different response formats
          if (data is List) {
            // Direct array response
            print('🔥 Processing downloads as direct List');
            return data.map((e) => DownloadImageModel.fromJson(e)).toList();
          } else if (data is Map<String, dynamic>) {
            // Object response - check for common patterns
            print('🔥 Processing downloads as Map response');
            
            if (data.containsKey('downloadedImage') && data['downloadedImage'] is List) {
              // Response like: { "downloadedImage": [...], "success": true }
              print('🔥 Found downloadedImage array in response');
              final List downloadsList = data['downloadedImage'];
              return downloadsList.map((e) => DownloadImageModel.fromJson(e)).toList();
            } else if (data.containsKey('downloadimages') && data['downloadimages'] is List) {
              // Response like: { "downloadimages": [...], "success": true }
              print('🔥 Found downloadimages array in response');
              final List downloadsList = data['downloadimages'];
              return downloadsList.map((e) => DownloadImageModel.fromJson(e)).toList();
            } else if (data.containsKey('downloadImages') && data['downloadImages'] is List) {
              // Response like: { "downloadImages": [...], "success": true }
              print('🔥 Found downloadImages array in response');
              final List downloadsList = data['downloadImages'];
              return downloadsList.map((e) => DownloadImageModel.fromJson(e)).toList();
            } else if (data.containsKey('downloads') && data['downloads'] is List) {
              // Response like: { "downloads": [...], "total": 5 }
              print('🔥 Found downloads array in response');
              final List downloadsList = data['downloads'];
              return downloadsList.map((e) => DownloadImageModel.fromJson(e)).toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              // Response like: { "data": [...], "success": true }
              print('🔥 Found data array in downloads response');
              final List downloadsList = data['data'];
              return downloadsList.map((e) => DownloadImageModel.fromJson(e)).toList();
            } else if (data.containsKey('result') && data['result'] is List) {
              // Response like: { "result": [...], "success": true }
              print('🔥 Found result array in downloads response');
              final List downloadsList = data['result'];
              return downloadsList.map((e) => DownloadImageModel.fromJson(e)).toList();
            } else {
              // Check if user data contains downloadimages
              if (data.containsKey('downloadimages')) {
                final downloadimages = data['downloadimages'];
                if (downloadimages is List) {
                  print('🔥 Found downloadimages in user data');
                  return downloadimages.map((e) => DownloadImageModel.fromJson(e)).toList();
                }
              }
              
              print('🔥 No recognized download array found. Available keys: ${data.keys.toList()}');
              return []; // Return empty list if no downloads
            }
          } else {
            print('🔥 Unexpected response type: ${data.runtimeType}');
            continue; // Try next endpoint
          }
        } else if (response.statusCode == 404) {
          // No downloads found
          print('🔥 No downloads found (404) on endpoint: $endpoint');
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
    print('🔥 All endpoints failed, returning empty list');
    return [];
  }








  // Remove from downloads (optional feature)
  Future<Map<String, dynamic>> removeFromDownloads(String imageId) async {
    final token = await _getSavedToken();
    final url = Uri.parse("$baseUrl/user/download/$imageId");

    print("🔥 Removing from downloads: $imageId");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token ?? "",
        },
      );

      print("🔥 Remove download response status: ${response.statusCode}");
      print("🔥 Remove download response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("🔥 Image removed from downloads successfully");
        
        if (response.body.isEmpty) {
          return {"success": true, "message": "Image removed from downloads successfully"};
        }

        try {
          return jsonDecode(response.body);
        } catch (jsonError) {
          print("🔥 JSON decode error: $jsonError");
          return {"success": true, "message": "Image removed from downloads successfully"};
        }
      } else {
        print("🔥 Remove download API Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to remove from downloads: ${response.statusCode} → ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception removing from downloads: $e");
      throw Exception("Failed to remove from downloads: $e");
    }
  }
}