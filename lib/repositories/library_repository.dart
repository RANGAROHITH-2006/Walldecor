// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/models/all_library_model.dart';
import 'package:walldecor/models/categorydetailes_model.dart';
import 'package:walldecor/models/library_details_model.dart';

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
        "Authorization": token ?? "",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Library created successfully");
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed: ${response.statusCode} → ${response.body}");
    }
  }


  Future<List<AllLibraryModel>> fetchLibraryData() async {
    final token = await _getSavedToken();
    print(' Using token: $token');

    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/library');
    print(' Fetching from URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔥 Raw API response type: ${data.runtimeType}');
        print('🔥 Raw API response: $data');

        // Handle different response formats
        if (data is List) {
          // Direct array response
          print('🔥 Processing as direct List');
          return data.map((e) => AllLibraryModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          // Object response - check for common patterns
          print('🔥 Processing as Map response');
          
          if (data.containsKey('data') && data['data'] is List) {
            // Response like: { "data": [...], "success": true }
            print('🔥 Found data array in response');
            final List libraryList = data['data'];
            return libraryList.map((e) => AllLibraryModel.fromJson(e)).toList();
          } else if (data.containsKey('libraries') && data['libraries'] is List) {
            // Response like: { "libraries": [...], "total": 5 }
            print('🔥 Found libraries array in response');
            final List libraryList = data['libraries'];
            return libraryList.map((e) => AllLibraryModel.fromJson(e)).toList();
          } else if (data.containsKey('result') && data['result'] is List) {
            // Response like: { "result": [...], "success": true }
            print('🔥 Found result array in response');
            final List libraryList = data['result'];
            return libraryList.map((e) => AllLibraryModel.fromJson(e)).toList();
          } else {
            // If it's a single library object, wrap it in a list
            print('🔥 Single library object detected');
            try {
              final library = AllLibraryModel.fromJson(data);
              return [library];
            } catch (e) {
              print('🔥 Failed to parse as single library: $e');
              throw Exception('Unexpected response format. Expected array or object with data/libraries/result field, got: $data');
            }
          }
        } else {
          throw Exception('Expected List or Map but got ${data.runtimeType}: $data');
        }
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print(' Error fetching library data: $e');
      throw Exception('Failed to fetch library data: $e');
    }
  }

  Future<Map<String, dynamic>> updateLibrary(
    String libraryId, {
    required Urls urls,
    required User user,
  }) async {
    final token = await _getSavedToken();
    final url = Uri.parse("$baseUrl/library/update/$libraryId");
    final imageId = "img_${DateTime.now().millisecondsSinceEpoch}";

    final requestBody = {
      "id": imageId,
      "urls": urls.toJson(),
      "user": user.toJson(),
    };

    print(" Updating library ID: $libraryId");
    print(" Request body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token ?? "",
        },
        body: jsonEncode(requestBody),
      );

      print(" Response status: ${response.statusCode}");
      print(" Response body: ${response.body}");

      // ----- SUCCESS -----
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" Library update API call successful");

        if (response.body.isEmpty) {
          return {"success": true, "message": "Library updated successfully"};
        }

        return jsonDecode(response.body);
      }

      // ----- ERROR -----
      print(" API Error: ${response.statusCode} - ${response.body}");
      throw Exception(
        "Failed to update library: ${response.statusCode} → ${response.body}",
      );
    } catch (e) {
      print(" Exception updating library: $e");

      return {"success": false, "error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> renameLibrary(
    String libraryId, {
    required String libraryName,
  }) async {
    final token = await _getSavedToken();

    final url = Uri.parse("$baseUrl/library/rename/$libraryId");

    final requestBody = {"libraryName": libraryName};

    print(" Renaming library ID: $libraryId");
    print(" New library name: $libraryName");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token ?? "",
        },
        body: jsonEncode(requestBody),
      );

      print(" Response status: ${response.statusCode}");
      print(" Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(" Library renamed successfully");

        // Handle different response types
        if (response.body.isEmpty) {
          return {"success": true, "message": "Library renamed successfully"};
        }

        try {
          final responseData = jsonDecode(response.body);

          if (responseData is String) {
            return {"success": true, "message": responseData};
          }

          if (responseData is Map<String, dynamic>) {
            return responseData;
          }

          return {"success": true, "data": responseData};
        } catch (jsonError) {
          print(" JSON decode error: $jsonError");
          return {"success": true, "message": response.body};
        }
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        throw Exception(
          "Failed to rename library: ${response.statusCode} → ${response.body}",
        );
      }
    } catch (e) {
      print(" Exception renaming library: $e");
      throw Exception("Failed to rename library: $e");
    }
  }




    Future<List<LibraryDetailsModel>> fetchLibraryDetailedData(String id) async {
    final token = await _getSavedToken();
    print('🔥 Using token: $token');
    if (token == null || token.isEmpty) {
      throw Exception('Guest token not found in SharedPreferences');
    }

    final url = Uri.parse('$baseUrl/library/$id');
    print('🔥 Fetching library details from URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, 
        },
      );

      print('🔥 Library details response status: ${response.statusCode}');
      print('🔥 Library details response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔥 Raw library details response type: ${data.runtimeType}');

        // Handle different response formats
        if (data is List) {
          // Direct array response - each item should be a LibraryDetailsModel
          print('🔥 Processing library details as direct List');
          return data.map((e) => LibraryDetailsModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic>) {
          // Object response - likely a single library object
          print('🔥 Processing library details as Map response');
          
          if (data.containsKey('savedImage') && data['savedImage'] is List) {
            // Response is a library object with savedImage array
            // We need to return the savedImage items as LibraryDetailsModel objects
            print('🔥 Found savedImage array in library details response');
            
            // Since LibraryDetailsModel expects individual saved images, we need to create
            // a single LibraryDetailsModel with the savedImage array
            return [LibraryDetailsModel.fromJson(data)];
          } else if (data.containsKey('data') && data['data'] is List) {
            // Response like: { "data": [...], "success": true }
            print('🔥 Found data array in library details response');
            final List detailsList = data['data'];
            return detailsList.map((e) => LibraryDetailsModel.fromJson(e)).toList();
          } else {
            // If it's a single library detail object, wrap it in a list
            print('🔥 Single library detail object detected');
            try {
              final libraryDetail = LibraryDetailsModel.fromJson(data);
              return [libraryDetail];
            } catch (e) {
              print('🔥 Failed to parse as single library detail: $e');
              throw Exception('Unexpected library details response format. Expected array or object with savedImage/data field, got: $data');
            }
          }
        } else {
          throw Exception('Expected List or Map but got ${data.runtimeType} for library details: $data');
        }
      } else {
        print("🔥 Library details API error: ${response.statusCode} → ${response.body}");
        throw Exception('Failed to fetch library details: ${response.statusCode} → ${response.body}');
      }
    } catch (e) {
      print('🔥 Exception fetching library details: $e');
      throw Exception('Failed to fetch library details: $e');
    }
  }
}
