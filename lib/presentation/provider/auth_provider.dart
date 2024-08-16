import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthRepository _authRepository = getIt<AuthRepository>();

  User? get currentUser => _authRepository.currentUser;

  bool get isLoggedIn => currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthenticationProvider() {
    _authRepository.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(email, password);
    result.fold((failure) {
      log("error ${failure.message}");
      _errorMessage = failure.message;
    }, (_) {});

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.register(email, password);
    result.fold((failure) {
      _errorMessage = failure.message;
    }, (_) {});

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
