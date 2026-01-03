class AppUser {
  final String uid;
  final String email;
  final String role; // patient | doctor

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'],
      role: data['role'],
    );
  }
}
