import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthRepository _authRepository = getIt<AuthRepository>();

  User? get currentUser => _authRepository.currentUser;

  bool get isLoggedIn => currentUser != null;

  AuthenticationProvider() {
    _authRepository.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _authRepository.login(email, password);
  }

  Future<void> register(String email, String password) async {
    await _authRepository.register(email, password);
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
