import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  final String groupName;

  AttendanceMarkingScreen({required this.groupName});

  @override
  _AttendanceMarkingScreenState createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  Map<String, bool> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    try {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupName).get();

      if (!groupDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Группа не найдена.')));
        return;
      }

      final students = List<String>.from(groupDoc['students']);
      setState(() {
        _attendance = {for (var student in students) student: true};
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      print('Ошибка в _loadGroupData: $e');
    }
  }

  Future<void> _submitAttendance() async {
    final absentees = _attendance.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    await FirebaseFirestore.instance.collection('attendance').doc(widget.groupName).update({
      'absentees': absentees,
      'expectedCount': _attendance.length,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Посещение сохранено')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Отметить студентов')),
      body: _attendance.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          for (var student in _attendance.keys)
            CheckboxListTile(
              title: Text(student),
              value: _attendance[student],
              onChanged: (value) {
                setState(() {
                  _attendance[student] = value!;
                });
              },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitAttendance,
            child: Text('Сохранить посещение'),
          ),
        ],
      ),
    );
  }
}
