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

  Future<bool> register(String email, String password) async {
    log("start register");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    var isSucceed = false;

    final result = await _authRepository.register(email, password);
    result.fold((failure) {
      _errorMessage = failure.message;
      isSucceed = false;
    }, (_) {
      isSucceed = true;
    });

    _isLoading = false;
    log("finish register");
    notifyListeners();
    return isSucceed;
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
