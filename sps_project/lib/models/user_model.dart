class UserModel {
  final String id;
  final String name;
  final String role; // "Староста группы" или "Преподаватель"
  final String? groupId; // Только для старосты

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'groupId': groupId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      groupId: map['groupId'],
    );
  }
}