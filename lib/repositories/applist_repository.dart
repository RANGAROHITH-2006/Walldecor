import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:walldecor/models/applist_model.dart';

class ApplistRepository {
  final String apiUrl = 'https://boilerplate.zooq.app/appList/v2';
  final String imageBaseUrl = 'https://applist.sgp1.digitaloceanspaces.com/';

  Future<ApplistModel> fetchAppList() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic rawData = jsonDecode(response.body);
        print('API Response Type: ${rawData.runtimeType}');
        print('API Response: $rawData');
        
        if (rawData is List) {
          // The API returns an array with a single object containing zooq and tools_brain
          if (rawData.isNotEmpty) {
            final Map<String, dynamic> data = rawData[0];
            print('Parsed Data: $data');
            return ApplistModel.fromJson(data);
          } else {
            throw Exception('Empty response from API');
          }
        } else if (rawData is Map<String, dynamic>) {
          // Direct object response
          return ApplistModel.fromJson(rawData);
        } else {
          throw Exception('Unexpected response format: ${rawData.runtimeType}');
        }
      } else {
        throw Exception('Failed to fetch app list: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching app list: $e');
      throw Exception('Error fetching app list: $e');
    }
  }

  String getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return imageBaseUrl + imagePath;
  }
}