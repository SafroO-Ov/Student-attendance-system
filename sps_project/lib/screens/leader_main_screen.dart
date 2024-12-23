import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderMainScreen extends StatelessWidget {
  Future<void> _checkAndNavigateToAttendanceMarking(BuildContext context) async {
    try {
      // Получаем ID текущего пользователя
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Получаем документ пользователя
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('groupNumber')) {
        throw Exception('Поле "groupNumber" отсутствует у пользователя');
      }

      // Используем groupNumber
      final groupNumber = userDoc['groupNumber'];

      // Проверяем, существует ли документ в коллекции attendance
      final attendanceDoc = await FirebaseFirestore.instance.collection('attendance').doc(groupNumber).get();

      if (attendanceDoc.exists) {
        Navigator.pushNamed(context, '/attendanceMarking', arguments: {'groupName': groupNumber});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Документ для вашей группы не найден.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
      print('Ошибка в _checkAndNavigateToAttendanceMarking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Главная: Староста')),
      body:
          Align(alignment: Alignment.center,
            child:
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _checkAndNavigateToAttendanceMarking(context),
                  child: Text('Отметить студентов'),
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
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
