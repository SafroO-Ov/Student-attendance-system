import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupSelectionScreen extends StatefulWidget {
  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _groups = [];
  final Set<String> _selectedGroups = {};

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('groups').get();
    setState(() {
      _groups = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  void _onSubmit() {
// Передать выбранные группы на следующий экран
    Navigator.pushNamed(
        context,
        '/teacherPhoto',
        arguments: _selectedGroups.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Выберите группы')),
      body: _groups.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return CheckboxListTile(
            title: Text(group),
            value: _selectedGroups.contains(group),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedGroups.add(group);
                } else {
                  _selectedGroups.remove(group);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmit,
        child: Icon(Icons.check),
      ),
    );
  }
}