import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  RegisterScreen({required this.role});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController groupController = TextEditingController();
  final List<String> students = [];

  void _addStudent() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController studentController = TextEditingController();
        return AlertDialog(
          title: Text('Добавить студента'),
          content: TextField(controller: studentController, decoration: InputDecoration(labelText: 'ФИО студента')),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  students.add(studentController.text);
                });
                Navigator.pop(context);
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация: ${widget.role}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'ФИО')),
            if (widget.role == 'Староста группы') ...[
              TextField(controller: groupController, decoration: InputDecoration(labelText: 'Номер группы')),
              ElevatedButton(onPressed: _addStudent, child: Text('Добавить студента')),
              ...students.map((s) => ListTile(title: Text(s))),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
// Сохранение данных пользователя в базе
              },
              child: Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}