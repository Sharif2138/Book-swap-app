class UserModel {
  String id;
  String name;
  String email;
  String? imageUrl;
  bool isEmailVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.isEmailVerified
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      isEmailVerified: map['isEmailVerified']
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'imageUrl': imageUrl ?? '', 'isEmailVerified': isEmailVerified};
  }
}
