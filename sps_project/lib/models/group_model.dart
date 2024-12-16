class GroupModel {
  final String id;
  final String name;
  final List<String> students;

  GroupModel({
    required this.id,
    required this.name,
    required this.students,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'students': students,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'],
      name: map['name'],
      students: List<String>.from(map['students']),
    );
  }
}