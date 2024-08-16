import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> authStateChanges();
  Future<UserCredential> login(String email, String password);
  Future<UserCredential> register(String email, String password);
  Future<void> logout();
}
