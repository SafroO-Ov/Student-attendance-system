import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageService {
  static Future<int> sendImageToServer(File imageFile) async {
    final uri = Uri.parse("http://<SERVER_IP>:8080/countFaces"); // Замените <SERVER_IP> на IP сервера

    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['count']; // Возвращает количество лиц
    } else {
      throw Exception('Failed to process image');
    }
  }
}