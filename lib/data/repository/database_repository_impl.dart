import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eitherx/eitherx.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';
import 'package:flutter_twitter_clone/domain/repository/database_repository.dart';

/* DATABASE REPOSITORY IMPLEMENTATION
*
* This class handles all the data from and to firebase
*
* ______________________________
*
* - user profile
* - post message
* - like
* - comments
* - account stuff (report / block / delete account)
* - follow / unfollow
* - search users
*/

class DatabaseRepositoryImpl implements DatabaseRepository {
  //get instance of firestore and auth
  final _db = getIt<FirebaseFirestore>();
  final _auth = getIt<AuthRepository>();

  DatabaseRepositoryImpl() {
    _db.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  /* 
   * USER PROFILE
   *
   * when a new user registers, we create an account for then,
   * but let's also store their details in the database to display on their profile page
   */

  // Save user info

  @override
  Future<Either<Failure, Unit>> saveUserProfile(
      {required String name, required String email}) async {
    // get current uid
    String uid = _auth.currentUser!.uid;

    // extract user name from email
    String username = email.split('@')[0];

    // create a user profile
    UserProfile userProfile = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: "",
    );

    // convert user into a map so we can store in firebase
    final userMap = userProfile.toMap();

    // save the user info in firestore
    try {
      await _db.collection("Users").doc(uid).set(userMap);
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure("Error saveUserProfile"));
    }
  }

  // Get user info
  @override
  Future<Either<Failure, UserProfile?>> getUserProfile(String uid) async {
    try {
      // retrieve user doc from firebase
      DocumentSnapshot userDoc = await _db.collection('Users').doc(uid).get();

      // convert doc to user profile
      return Right(UserProfile.fromDocument(userDoc));
    } on FirebaseException catch (e) {
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserBio(String bio) async {
    // get current uid
    String uid = _auth.currentUser!.uid;

    // attempt to update in firebase
    try {
      await _db.collection('Users').doc(uid).update({'bio': bio});
      return const Right(unit);
    } catch (e) {
      return const Left(ServerFailure("Error updateUserBio"));
    }
  }

  /*
    MESSAGE
  */

  // Post a message
  @override
  Future<Either<Failure, Unit>> postMessage(String message) async {
    try {
      String uid = _auth.currentUser!.uid;

      final resultUser = await getUserProfile(uid);

      if (resultUser.isLeft) {
        return Left(resultUser.leftOrNull()!);
      } else if (resultUser.isRight) {
        UserProfile? user = resultUser.rightOrNull();
        Post newPost = Post(
          id: '',
          uid: uid,
          name: user!.name,
          username: user.username,
          message: message,
          timestamp: Timestamp.now(),
          likeCount: 0,
          likedBy: [],
        );

        // convert post object to map
        await _db.collection('Posts').add(newPost.toMap());
        return const Right(unit);
      }

      return const Left(ServerFailure("Error getUserProfile"));
    } on FirebaseException catch (e) {
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  // Delete a message
  @override
  Future<Either<Failure, Unit>> deletePost(String postId) async {
    try {
      await _db.collection('Posts').doc(postId).delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  // Get all posts from firebase
  @override
  Stream<Either<Failure, List<Post>>> getAllPosts() {
    try {
      return _db
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map<Either<Failure, List<Post>>>((snapshot) {
        final posts =
            snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
        return Right(posts);
      }).handleError((error) {
        return Left(ServerFailure('Failed to fetch posts: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to fetch posts: $e')));
    }
  }

  // Get individuaal post
  @override
  Stream<Either<Failure, List<Post>>> getPostsUID(String uid) {
    try {
      return _db
          .collection('Posts')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map<Either<Failure, List<Post>>>((snapshot) {
        final posts =
            snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
        return Right(posts);
      }).handleError((error) {
        return Left(ServerFailure('Failed to fetch posts: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to fetch posts: $e')));
    }
  }

  /*
    LIKES
  */

  // like a post
  @override
  Future<Either<Failure, Unit>> toggleLikeInFirebase(String postId) async {
    try {
      log('toggleLikeInFirebase');

      //get current uid
      String uid = _auth.currentUser!.uid;

      //go to doc for this post
      DocumentReference postDoc = _db.collection('Posts').doc(postId);

      //execute like
      await _db.runTransaction(
        (transaction) async {
          // get post data
          DocumentSnapshot postSnapshot = await transaction.get(postDoc);

          // get like of users who like the post
          List<String> likedBy =
              List<String>.from(postSnapshot['likedBy'] ?? []);

          // get like count
          int currentLikeCount = postSnapshot['likeCount'];

          // if user has not liked this post yet -> then like
          if (!likedBy.contains(uid)) {
            // add user to like list
            likedBy.add(uid);
            currentLikeCount++;
          }

          // if user has already liked this post -> then unlike
          else {
            // remove user from like list
            likedBy.remove(uid);

            // decrement like count
            currentLikeCount--;
          }

          // update firebase
          log('likeCount $currentLikeCount');
          log('likedby ${likedBy.length}');
          transaction.update(
            postDoc,
            {
              'likeCount': currentLikeCount,
              'likedBy': likedBy,
            },
          );
        },
      );
      return const Right(unit);
    } on FirebaseException catch (e) {
      log("error ${e.code}");
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      log("error $e");
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }
}
