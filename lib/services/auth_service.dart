import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(name);
    final user = UserModel(
      id: credential.user!.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.id).set(user.toJson());
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromJson(doc.data()!);
        // If id is empty (legacy doc), patch it with the real uid
        if (user.id.isEmpty) {
          return user.copyWith(id: uid, email: credential.user!.email ?? email);
        }
        return user;
      }
    } catch (_) {}
    return UserModel(
      id: uid,
      name: credential.user!.displayName ?? '',
      email: credential.user!.email ?? email,
      createdAt: DateTime.now(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) return UserModel.fromJson(doc.data()!);
      return UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        createdAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
