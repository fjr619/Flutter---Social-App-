import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/model/comment.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/following.dart';
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
    showLoading();

    final result =
        await databaseRepository.saveUserProfile(name: name, email: email);
    result.fold((failure) {}, (unit) {});

    _isSaveUserProfile = true;
    hideLoading();
  }

  void showLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void hideLoading() {
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

  Future<void> deleteUserInfo() async {
    showLoading();
    await databaseRepository.deleteUserInfo();
    hideLoading();
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

  Stream<List<Post>> loadAllPostsa() {
    return databaseRepository.getAllPosts().map(
      (either) {
        return either.fold(
          (failure) {
            return [];
          },
          (data) {
            return data;
          },
        );
      },
    );
  }

  Stream<Either<Failure, List<Post>>> getUserPosts(String uid) {
    return databaseRepository.getPostsUID(uid);
  }

  Stream<Either<Failure, Post>> getPost(String postId) {
    return databaseRepository.getPost(postId);
  }

  Future<void> deletePost(String postId) async {
    await databaseRepository.deletePost(postId);
  }

  @override
  void dispose() {
    super.dispose();
    log('[rpvoder dispose]');
  }

  /*
  LIKES
  */

  Future<void> likePost(String postId) async {
    await databaseRepository.toggleLikeInFirebase(postId);
  }

  /*
    COMMENTS
  */

  Future<void> postComment(String comment, Post post) async {
    await databaseRepository.addComment(post.id, comment);
  }

  Stream<Either<Failure, List<Comment>>> loadPostComments(String postId) {
    return databaseRepository.getPostComments(postId);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await databaseRepository.deleteComment(postId, commentId);
  }

  /*
    ACCOUNT STUFF
  */

  //report post
  Future<void> reportUser(String postId, String userId) async {
    await databaseRepository.reportUser(postId, userId);
  }

  //block user
  Future<void> blockUser(String userId) async {
    await databaseRepository.blockUser(userId);
  }

  // unblock user
  Future<void> unblockUser(String userId) async {
    await databaseRepository.unblockUser(userId);
  }

  // get list of blocked user ids
  Stream<List<UserProfile>> getBlockedUids() {
    return databaseRepository.getBlockedUids();
  }

  /*
    FOLLOWING
  */

  Future<void> followUser(String targetUid) async {
    await databaseRepository.followUser(targetUid);
  }

  Future<void> unfollowUser(String targetUid) async {
    await databaseRepository.unfollowUser(targetUid);
  }

  Stream<List<Following>> getFollowers(String uid) {
    return databaseRepository.getFollowers(uid);
  }

  Stream<List<Following>> getFollowing(String uid) {
    return databaseRepository.getFollowing(uid);
  }

  Stream<bool> isUserFollowed(String uid) {
    return databaseRepository.isUserFollowed(uid);
  }

  Stream<List<Post>> getFollowingPosts() {
    return databaseRepository.getFollowingPosts();
  }

  /*
    SEARCH
   */

  Future<List<UserProfile>> searchUsers(String searchTerm) {
    return databaseRepository.searchUsers(searchTerm);
  }
}
