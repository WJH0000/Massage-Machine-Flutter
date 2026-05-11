import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Uint8ListConverter {
  //convert network image to Uint8List
  static Future<Uint8List> networkImageToUint8List(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));

    final bytes = response.bodyBytes;

    String base64 = base64Encode(bytes);

    return base64Decode(base64);
  }
}
