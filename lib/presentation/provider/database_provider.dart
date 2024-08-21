import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';
import 'package:flutter_twitter_clone/domain/repository/database_repository.dart';

/*
 * DATABASE PROVIDER
 * 
 * This provider is to seperate the firestore data handling and the UI of our app,
 * 
 * - the database repository handles data to and from firestore
 * - the database provider class processes the data to display in our app
 * 
 * This is to make our code much more modular, cleaner and easier to read and test
 * Particularly as the number of pages grow, we need this provider to properly manage the different state of the app.
 * 
 * - Also. if one day,we decide to change our backend (from firebase to something else), then it's much easier to do manage and switch out
 */

class DatabaseProvider extends ChangeNotifier {
  final DatabaseRepository databaseRepository = getIt<DatabaseRepository>();

  DatabaseProvider() {
    log('init databaseprovider');
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSaveUserProfile = false;
  bool get isSaveUserProfile => _isSaveUserProfile;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<void> saveUserProfile(
      {required String name, required String email}) async {
    log("start saveUserProfile");
    _isSaveUserProfile = false;
    showDialog();

    await Future.delayed(const Duration(seconds: 2));

    final result =
        await databaseRepository.saveUserProfile(name: name, email: email);
    result.fold((failure) {}, (unit) {});

    _isSaveUserProfile = true;
    hideDialog();
  }

  void showDialog() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void hideDialog() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getUserProfile(String uid) async {
    // _isLoading = true;
    // _errorMessage = null;
    // notifyListeners();

    final result = await databaseRepository.getUserProfile(uid);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {
        _userProfile = data;
      },
    );

    log("user ${userProfile?.name}");

    // _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserBio(String bio) async {
    final result = await databaseRepository.updateUserBio(bio);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (data) {},
    );
  }

  /*
    POSTS
  */

  Future<void> postMessage(String message) async {
    await databaseRepository.postMessage(message);
  }

  Stream<Either<Failure, List<Post>>> loadAllPosts() {
    return databaseRepository.getAllPosts();
  }

  Future<List<Post>> getUserPosts(String uid) async {
    final result = await databaseRepository.getPostsUID(uid);

    return result.fold(
      (failure) {
        // You can either handle the failure here or throw an exception
        throw Exception(failure.message);
        // return []; // Alternatively, return an empty list instead of throwing an error
      },
      (posts) {
        return posts; // Return the list of posts
      },
    );
  }
}
