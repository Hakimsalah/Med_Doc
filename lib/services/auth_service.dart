import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = result.user!.uid;
    final snap = await _db.collection('users').doc(uid).get();

    if (!snap.exists) {
      throw Exception("User role not found");
    }

    return snap.get('role');
  }

  Future<void> registerPatient(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(result.user!.uid).set({
      'email': email,
      'role': 'patient',
      'createdAt': Timestamp.now(),
    });
  }
}
