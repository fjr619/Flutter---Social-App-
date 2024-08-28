import 'package:eitherx/eitherx.dart';
import 'package:flutter_twitter_clone/domain/model/comment.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';

abstract class DatabaseRepository {
  Future<Either<Failure, Unit>> saveUserProfile(
      {required String name, required String email});
  Future<Either<Failure, UserProfile?>> getUserProfile(String uid);
  Future<Either<Failure, Unit>> updateUserBio(String bio);
  Future<void> deleteUserInfo();

  Future<Either<Failure, Unit>> postMessage(String message);
  Stream<Either<Failure, List<Post>>> getAllPosts();
  Stream<Either<Failure, List<Post>>> getPostsUID(String uid);
  Stream<Either<Failure, Post>> getPost(String id);

  Future<Either<Failure, Unit>> deletePost(String postId);
  Future<Either<Failure, Unit>> toggleLikeInFirebase(String postId);

  Future<Either<Failure, Unit>> addComment(String postId, String message);
  Future<Either<Failure, Unit>> deleteComment(String postId, String commentId);
  Stream<Either<Failure, List<Comment>>> getPostComments(String postId);

  Future<void> reportUser(String postId, String userId);
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Stream<List<UserProfile>> getBlockedUids();
}
