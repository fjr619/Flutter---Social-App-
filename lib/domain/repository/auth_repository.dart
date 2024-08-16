import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> authStateChanges();
  Future<Either<Failure, UserCredential>> login(String email, String password);
  Future<Either<Failure, UserCredential>> register(
      String email, String password);
  Future<void> logout();
}
