import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  Future<void> registerUser(String email, String password, String role) async {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'role': role,
    });
  }

  Future<void> loginUser(String email, String password, Function(String) onRoleDetermined) async {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
    String role = userData['role'];

    onRoleDetermined(role);
  }
}
