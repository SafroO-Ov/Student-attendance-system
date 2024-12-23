import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sps_project/screens/group_selection_screen.dart';
import 'package:sps_project/screens/group_students_screen.dart';
import 'package:sps_project/screens/leader_main_screen.dart';
import 'package:sps_project/screens/teacher_main_screen.dart';
import 'package:sps_project/screens/teacher_photo_screen.dart';
import 'package:sps_project/screens/results_screen.dart';
import 'package:sps_project/screens/attendance_marking_screen.dart';
import 'screens/login_screen.dart'; // Импорт экрана входа
import 'package:cloud_firestore/cloud_firestore.dart';

// Глобальный NavigatorKey для управления маршрутами
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Глобальный NavigatorKey
      initialRoute: '/login',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/attendanceMarking') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null || !args.containsKey('groupName')) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Ошибка')),
                body: Center(
                  child: Text('Не удалось загрузить данные.'),
                ),
              ),
            );
          }

          return MaterialPageRoute(
            builder: (context) => AttendanceMarkingScreen(
              groupName: args['groupName'],
            ),
          );
        }
        return null;
      },
      routes: {
        '/login': (context) => LoginScreen(),
        '/leaderMain': (context) => LeaderMainScreen(),
        '/groupStudents': (context) => GroupStudentsScreen(),
        '/teacherMain': (context) => TeacherMainScreen(),
        '/groupSelection': (context) => GroupSelectionScreen(),
        '/teacherPhoto': (context) => TeacherPhotoScreen(),
        '/results': (context) => ResultsScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
