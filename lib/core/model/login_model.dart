class UserModel {
  final String uid;
  final String email;
  final String username;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
  });

  // Convert a UserModel into a Map عشان ارجعها للفايرستور
  Map<String, dynamic> toMap() {
    return {
      'uid' : uid,
      'email' : email,
      'username' : username,
    };
  }

  // Convert a Map into a UserModel عشان اجيبها من الفايرستور
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '', 
      email: map['email'] ?? '', 
      username: map['username'] ?? '',
    );
  }
}