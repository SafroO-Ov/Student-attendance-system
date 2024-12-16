import 'package:flutter/material.dart';
import 'package:sps_project/screens/group_selection_screen.dart';
import 'teacher_photo_screen.dart'; // Для перехода на экран фотографирования

class TeacherMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Главная: Преподаватель')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroupSelectionScreen()),
            );
          },
          child: Text('Проверить количество студентов'),
        ),
      ),
    );
  }
}