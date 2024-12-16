import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherPhotoScreen extends StatefulWidget {
  @override
  _TeacherPhotoScreenState createState() => _TeacherPhotoScreenState();
}

class _TeacherPhotoScreenState extends State<TeacherPhotoScreen> {
  File? _image;
  int? _facesCount;
  List<String> _selectedGroups = [];
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedGroups = ModalRoute.of(context)!.settings.arguments as List<String>;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<int> _uploadImage() async {
    if (_image == null) throw Exception("Изображение не выбрано");

    setState(() {
      _isLoading = true;
    });

    final request = http.MultipartRequest('POST', Uri.parse("http://192.168.31.106:5000/process"));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      setState(() {
        _facesCount = data['count'];
      });

      return _facesCount!;
    } else {
      throw Exception("Ошибка обработки изображения");
    }
  }

  Future<void> _sendNotifications() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Староста')
        .where('groupNumber', whereIn: _selectedGroups)
        .get();

    for (var doc in snapshot.docs) {
      final token = doc['fcmToken']; // Убедитесь, что токены FCM сохранены в базе
      if (token != null) {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Authorization': 'key=<Your-Server-Key>',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': 'Преподаватель',
          'notification': {
            'title': 'Отметьте студентов',
            'body': 'Преподаватель выбрал вашу группу. Отметьте отсутствующих студентов.',
          },
          'data': {
            'group': doc['groupNumber'],
          },
        }),
      );
      }
    }
  }

  Future<void> _processPhoto() async {
    try {
      final facesCount = await _uploadImage();
      await _sendNotifications();

      Navigator.pushNamed(context, '/results', arguments: {
        'facesCount': facesCount,
        'selectedGroups': _selectedGroups,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Сделать фото аудитории')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image == null
              ? Text('Фото не сделано')
              : Image.file(_image!),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Сделать фото'),
          ),
          if (_image != null)
            ElevatedButton(
              onPressed: _processPhoto,
              child: Text('Отправить фото'),
            ),
        ],
      ),
    );
  }
}