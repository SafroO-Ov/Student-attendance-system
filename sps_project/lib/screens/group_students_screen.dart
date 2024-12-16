import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupStudentsScreen extends StatefulWidget {
  @override
  _GroupStudentsScreenState createState() => _GroupStudentsScreenState();
}

class _GroupStudentsScreenState extends State<GroupStudentsScreen> {
  final TextEditingController _studentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _groupNumber;
  List<String> _students = [];

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
// Получаем ID текущего пользователя
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован.');
      }

      final userId = user.uid;
      print('Загружаем данные для пользователя с ID: $userId');

// Получаем документ пользователя
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('Пользователь не найден в базе данных.');
      }

      final groupNumber = userDoc['groupNumber'];

// Получаем данные группы
      final groupDoc = await _firestore.collection('groups').doc(groupNumber).get();
      if (groupDoc.exists) {
        setState(() {
          _groupNumber = groupNumber;
          _students = List<String>.from(groupDoc['students'] ?? []);
        });
      } else {
// Если группы нет, создаём новую
        await _firestore.collection('groups').doc(groupNumber).set({
          'name': groupNumber,
          'students': [],
        });
        setState(() {
          _groupNumber = groupNumber;
          _students = [];
        });
      }
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки данных: ${e.toString()}')),
      );
    }
  }

  Future<void> _addStudent() async {
    if (_studentController.text.isNotEmpty) {
      final newStudent = _studentController.text.trim();
      setState(() {
        _students.add(newStudent);
      });

      try {
        await _firestore.collection('groups').doc(_groupNumber).set({
          'name': _groupNumber,
          'students': _students,
        }, SetOptions(merge: true));
        _studentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка добавления студента: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Группа $_groupNumber')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_students[index]));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _studentController,
              decoration: InputDecoration(
                labelText: 'Добавить студента',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addStudent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}