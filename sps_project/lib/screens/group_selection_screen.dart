import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupSelectionScreen extends StatefulWidget {
  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  List<String> _groups = [];
  List<String> _selectedGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final snapshot = await FirebaseFirestore.instance.collection('groups').get();
    setState(() {
      _groups = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _submitSelection() async {
    for (var group in _selectedGroups) {
      await FirebaseFirestore.instance.collection('attendance').doc(group).set({
        'groupName': group,
        'absentees': [],
        'expectedCount': 0,
      });
    }
    Navigator.pushNamed(context, '/teacherPhoto', arguments: _selectedGroups);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Выбор групп')),
      body: _groups.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          for (var group in _groups)
            CheckboxListTile(
              title: Text(group),
              value: _selectedGroups.contains(group),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedGroups.add(group);
                  } else {
                    _selectedGroups.remove(group);
                  }
                });
              },
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedGroups.isNotEmpty ? _submitSelection : null,
            child: Text('Продолжить'),
          ),
        ],
      ),
    );
  }
}
