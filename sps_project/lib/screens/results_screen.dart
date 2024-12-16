import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int facesCount = args['facesCount'];
    final int expectedCount = args['expectedCount'];
    final List<String> absentees = args['absentees'];

    return Scaffold(
      appBar: AppBar(title: Text('Результаты занятия')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Количество людей на фотографии: $facesCount', style: TextStyle(fontSize: 18)),
            Text('Ожидаемое количество по спискам: $expectedCount', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Отсутствующие студенты:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: absentees.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(absentees[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}