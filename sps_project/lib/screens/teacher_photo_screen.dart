import 'dart:convert';
import 'dart:io';
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

  Future<void> _uploadImageAndProcessAttendance() async {
    if (_image == null) throw Exception("Изображение не выбрано");

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse("http://192.168.43.117:5000/process"));
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        setState(() {
          _facesCount = (data['count'] as num).toInt(); // Преобразование num → int
        });

        // Ожидание данных старост
        await Future.delayed(Duration(minutes: 1));

        // Получение данных результатов
        final snapshot = await FirebaseFirestore.instance.collection('attendance').get();

        int expectedCount = 0;
        List<String> absentees = [];
        for (var doc in snapshot.docs) {
          final docData = doc.data();
          expectedCount += (docData['expectedCount'] as num).toInt() ?? 0;
          absentees.addAll(List<String>.from(docData['absentees'] ?? []));
        }

        Navigator.pushNamed(context, '/results', arguments: {
          'facesCount': _facesCount,
          'expectedCount': expectedCount,
          'absentees': absentees,
        });

        // Очистка документов
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        throw Exception("Ошибка обработки изображения");
      }
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
          _image == null ? Text('Фото не сделано') : Image.file(_image!),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Сделать фото'),
          ),
          if (_image != null)
            ElevatedButton(
              onPressed: _uploadImageAndProcessAttendance,
              child: Text('Отправить фото'),
            ),
        ],
      ),
    );
  }
}
