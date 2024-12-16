import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sps_project/screens/attendance_marking_screen.dart';
import 'package:sps_project/screens/group_selection_screen.dart';
import 'package:sps_project/screens/group_students_screen.dart';
import 'package:sps_project/screens/leader_main_screen.dart';
import 'package:sps_project/screens/teacher_main_screen.dart';
import 'package:sps_project/screens/teacher_photo_screen.dart';
import 'package:sps_project/screens/results_screen.dart';
import 'screens/login_screen.dart'; // Импорт экрана входа
import 'package:cloud_firestore/cloud_firestore.dart';

// Обработчик фоновых уведомлений
void _handleNotification(RemoteMessage message, BuildContext context) async {
  if (message.data['group'] != null) {
    final groupName = message.data['group'];

    try {
// Загрузка студентов из базы данных
      final groupStudents = await fetchGroupStudents(groupName);

// Если данные успешно загружены, открыть экран отметки студентов
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceMarkingScreen(
            students: groupStudents,
            groupName: groupName,
          ),
        ),
      ).then((attendanceData) {
        if (attendanceData != null) {
          final absentees = attendanceData['absentees'];
          final expectedCount = attendanceData['expectedCount'];

// Здесь вы можете отправить данные обратно преподавателю
          print('Отсутствующие студенты: $absentees');
          print('Ожидаемое количество: $expectedCount');
        }
      });
    } catch (e) {
// Обработайте ошибки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase

// Регистрация обработчика фоновых уведомлений
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  runApp(MyApp());
}

Future<List<String>> fetchGroupStudents(String groupName) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
// Получаем документ группы по имени
    final QuerySnapshot querySnapshot = await firestore
        .collection('groups')
        .where('name', isEqualTo: groupName)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Группа $groupName не найдена в базе данных.');
    }

// Предполагается, что имя группы уникально, берём первый документ
    final DocumentSnapshot groupDoc = querySnapshot.docs.first;
    return List<String>.from(groupDoc['students'] ?? []);
  } catch (e) {
    print('Ошибка загрузки студентов группы: $e');
    return [];
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login', // Начальный экран
      routes: {
        '/login': (context) => LoginScreen(),
        '/leaderMain': (context) => LeaderMainScreen(),
        '/groupStudents': (context) => GroupStudentsScreen(),
        '/teacherMain': (context) => TeacherMainScreen(),
        '/groupSelection': (context) => GroupSelectionScreen(),
        '/teacherPhoto': (context) => TeacherPhotoScreen(),
        '/results': (context) => ResultsScreen(), // Экран результатов
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
