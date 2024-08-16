/*

Auth Repository Implementation

This handles everything to do with authentication in firebase
____________________________

- login
- register
- logout
- delete account (required if you want to publish to app store)

*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  //login -> email and password
  @override
  Future<UserCredential> login(String email, String password) async {
    // attempt login
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    }

    // catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register
  @override
  Future<UserCredential> register(String email, String password) async {
    // attemp to register new user
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // logout
  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // delete account
}
