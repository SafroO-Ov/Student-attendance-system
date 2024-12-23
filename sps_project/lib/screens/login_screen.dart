import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _role;
  String _fio = "";
  String _groupNumber = "";
  String _password = "";
  bool _isLogin = true; // переключение между Входом и Регистрацией

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submit() async {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      try {
        if (_isLogin) {
// Вход
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: _getEmailFromFIO(_fio),
            password: _password,
          );

          DocumentSnapshot userData = await _firestore.collection('users').doc(userCredential.user!.uid).get();
          String role = userData['role'];

          if (role == 'Староста') {
            Navigator.pushReplacementNamed(context, '/leaderMain');
          } else if (role == 'Преподаватель') {
            Navigator.pushReplacementNamed(context, '/teacherMain');
          }
        } else {
// Регистрация
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: _getEmailFromFIO(_fio),
            password: _password,
          );

// Получение FCM-токена
          final fcmToken = await FirebaseMessaging.instance.getToken();
          print('FCM Token: $fcmToken');

          Map<String, dynamic> userData = {
            'fio': _fio,
            'role': _role,
            'fcmToken': fcmToken, // Добавляем FCM токен
          };

          if (_role == 'Староста') {
            userData['groupNumber'] = _groupNumber;
          }

          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userData);

          if (_role == 'Староста') {
            Navigator.pushReplacementNamed(context, '/leaderMain');
          } else if (_role == 'Преподаватель') {
            Navigator.pushReplacementNamed(context, '/teacherMain');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  String _getEmailFromFIO(String fio) {
    return "${fio.replaceAll(' ', '.').toLowerCase()}@app.com";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _role,
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
                validator: (value) => value == null ? 'Выберите роль' : null,
                decoration: InputDecoration(labelText: 'Роль'),
                items: [
                  DropdownMenuItem(
                    value: 'Староста',
                    child: Text('Староста группы'),
                  ),
                  DropdownMenuItem(
                    value: 'Преподаватель',
                    child: Text('Преподаватель'),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'ФИО'),
                validator: (value) => value == null || value.isEmpty ? 'Введите ФИО' : null,
                onSaved: (value) => _fio = value!,
              ),
              if (_role == 'Староста')
                TextFormField(
                  decoration: InputDecoration(labelText: 'Номер группы'),
                  validator: (value) =>
                  _role == 'Староста' && (value == null || value.isEmpty) ? 'Введите номер группы' : null,
                  onSaved: (value) => _groupNumber = value!,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Введите пароль' : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'Нет аккаунта? Регистрация' : 'Есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}