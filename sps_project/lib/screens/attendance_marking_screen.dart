import 'package:flutter/material.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  final List<String> students; // Список студентов группы
  final String groupName; // Имя группы

  AttendanceMarkingScreen({required this.students, required this.groupName});

  @override
  _AttendanceMarkingScreenState createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  final Map<String, bool> _attendance = {}; // Отслеживание посещаемости

  @override
  void initState() {
    super.initState();
    for (var student in widget.students) {
      _attendance[student] = true; // Изначально все студенты отмечены как присутствующие
    }
  }

  void _submitAttendance() {
    final absentStudents = _attendance.entries
        .where((entry) => !entry.value) // Фильтруем отсутствующих студентов
        .map((entry) => entry.key)
        .toList();

    Navigator.pop(context, {
      'absentees': absentStudents,
      'expectedCount': _attendance.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Отметить студентов (${widget.groupName})')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                return CheckboxListTile(
                  title: Text(student),
                  value: _attendance[student],
                  onChanged: (value) {
                    setState(() {
                      _attendance[student] = value!;
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitAttendance,
            child: Text('Завершить отметку'),
          ),
        ],
      ),
    );
  }
}