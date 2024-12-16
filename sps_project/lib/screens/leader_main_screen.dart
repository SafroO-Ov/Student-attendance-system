import 'package:flutter/material.dart';
import 'group_students_screen.dart';
import 'attendance_marking_screen.dart';

class LeaderMainScreen extends StatelessWidget {
  List<String> groupStudents = [];
  String groupName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная: Староста группы'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Здесь будут отображаться уведомления для старосты.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20), // Отступ между текстом и кнопкой
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendanceMarkingScreen(
                      students: groupStudents, // Список студентов
                      groupName: groupName, // Имя группы
                    ),
                  ),
                ).then((absentStudents) {
// Обработайте список отсутствующих
                  print('Отсутствующие студенты группы $groupName: $absentStudents');
                });
              },
              child: Text('Отметить посещаемость'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groupStudents');
              },
              child: Text('Управление студентами группы'),
            ),
          ],
        ),
      ),
    );
  }
}
