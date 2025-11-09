// lib/models/user_model.dart
class UserModel {
  String uid;
  String name;
  String email;
  

  UserModel({required this.uid, required this.name, required this.email, });

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'email': email };
}
