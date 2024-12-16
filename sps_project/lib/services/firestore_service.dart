import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveAttendance(String teacherFio, List<String> groups, int facesCount) async {
    await FirebaseFirestore.instance.collection('attendance').add({
      'teacher': teacherFio,
      'groups': groups,
      'facesCount': facesCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> createGroup(GroupModel group) async {
    await _db.collection('groups').doc(group.id).set(group.toMap());
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final snapshot = await _db.collection('groups').doc(groupId).get();
    if (snapshot.exists) {
      return GroupModel.fromMap(snapshot.data()!);
    }
    return null;
  }

  Future<List<QueryDocumentSnapshot>> getAttendanceForTeacher(String teacherId) async {
    final snapshots = await _db
        .collection('attendance')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshots.docs;
  }

  Future<void> saveGroup(String groupName, List<String> students) async {
  await FirebaseFirestore.instance.collection('groups').add({
  'name': groupName,
  'students': students,
  });
  }

  Future<List<String>> getGroups() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('groups').get();
  return snapshot.docs.map((doc) => doc['name'].toString()).toList();
  }
}