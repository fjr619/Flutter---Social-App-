import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/repository/database_repository.dart';

class FirestoreProvider extends ChangeNotifier {
  final DatabaseRepository databaseRepository = getIt<DatabaseRepository>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSaveUserProfile = false;
  bool get isSaveUserProfile => _isSaveUserProfile;

  Future<void> saveUserProfile(
      {required String name, required String email}) async {
    log("start saveUserProfile");
    _isSaveUserProfile = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final result =
        await databaseRepository.saveUserProfile(name: name, email: email);
    result.fold((failure) {}, (unit) {});

    _isLoading = false;
    _isSaveUserProfile = true;
    log("finish saveUserProfile $_isSaveUserProfile");
    notifyListeners();
  }
}
