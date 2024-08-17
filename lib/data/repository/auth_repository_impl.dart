/*

Auth Repository Implementation

This handles everything to do with authentication in firebase
____________________________

- login
- register
- logout
- delete account (required if you want to publish to app store)

*/

import 'package:eitherx/eitherx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = getIt<FirebaseAuth>();

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  //login -> email and password
  @override
  Future<Either<Failure, UserCredential>> login(
      String email, String password) async {
    // attempt login
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return Right(userCredential);
    }

    // catch any errors
    on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // register
  @override
  Future<Either<Failure, UserCredential>> register(
      String email, String password) async {
    // attemp to register new user
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return Right(userCredential);
    }

    // catch any errors
    on FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // logout
  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // delete account
}
