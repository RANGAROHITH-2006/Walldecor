import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadImageToGallery(String imageUrl) async {
  try {
    await Permission.storage.request();

    var response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;

      await Gal.putImageBytes(
        bytes,
        name: "wallpaper_${DateTime.now().millisecondsSinceEpoch}",
      );
    } 
  } catch (e) {
    throw("❌ Error: $e");
  }
}
