import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eitherx/eitherx.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/model/comment.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/following.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';
import 'package:flutter_twitter_clone/domain/repository/database_repository.dart';
import 'package:rxdart/rxdart.dart';

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

  // update user info
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

  // delete user info
  @override
  Future<void> deleteUserInfo() async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;

      WriteBatch batch = _db.batch();

      // update followers and following records
      QuerySnapshot userFollows =
          await _db.collection('Users').doc(uid).collection('Following').get();

      for (var followDoc in userFollows.docs) {
        Following following = Following.fromDocument(followDoc);
        await unfollowUser(following.uid);
      }

      // // dlete user doc
      // DocumentReference userDoc = _db.collection('Users').doc(uid);
      // batch.delete(userDoc);

      // Now handle the rest in parallel
      await Future.wait([
        // Delete user doc
        _db.collection('Users').doc(uid).get().then(
          (value) {
            batch.delete(value.reference);
          },
        ),

        // Delete user posts
        _db
            .collection('Posts')
            .where('uid', isEqualTo: uid)
            .get()
            .then((userPosts) {
          for (var post in userPosts.docs) {
            batch.delete(post.reference);
          }
        }),

        // Delete user comments
        _db
            .collection('Comments')
            .where('uid', isEqualTo: uid)
            .get()
            .then((userComments) async {
          for (var commentQuery in userComments.docs) {
            Comment comment = Comment.fromDocument(commentQuery);
            DocumentReference postDoc =
                _db.collection('Posts').doc(comment.postId);

            // Update comment count
            await _db.runTransaction(
              (transaction) async {
                DocumentSnapshot postSnapshot = await transaction.get(postDoc);
                int currentCommentCount = postSnapshot['commentCount'] ?? 0;
                if (currentCommentCount != 0) currentCommentCount--;
                transaction.update(
                  postDoc,
                  {'commentCount': currentCommentCount},
                );
              },
            );

            batch.delete(commentQuery.reference);
          }
        }),

        // Delete likes done by this user
        _db.collection('Posts').get().then((allPosts) {
          for (QueryDocumentSnapshot post in allPosts.docs) {
            Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
            var likedBy = postData['likedBy'] as List<dynamic>;

            if (likedBy.contains(uid)) {
              batch.update(
                post.reference,
                {
                  'likedBy': FieldValue.arrayRemove([uid]),
                  'likeCount': FieldValue.increment(-1),
                },
              );
            }
          }
        }),
      ]);

      // Commit batch after all parallel operations are done
      await batch.commit();

      // Delete user account
      await _auth.deleteUser();
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
          commentCount: 0,
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
      // Query comments with the specified postId
      QuerySnapshot commentsSnapshot = await _db
          .collection('Comments')
          .where('postId', isEqualTo: postId)
          .get();

      // Iterate over the comments and delete each one
      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      await _db.collection('Posts').doc(postId).delete();

      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  Stream<List<String>> getExcludedUserIdsStream(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  // Get all posts from firebase
  @override
  Stream<Either<Failure, List<Post>>> getAllPosts() {
    try {
      String uid = _auth.currentUser!.uid;

      // Stream untuk mendapatkan blockedUserId secara real-time
      Stream<List<String>> blockedUserIdStream = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('BlockedUsers')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());

      // Stream untuk mendapatkan posts dari Firestore
      Stream<QuerySnapshot> postsStream = _db
          .collection('Posts')
          .orderBy('timestamp', descending: true)
          .snapshots();

      // Gabungkan kedua stream menggunakan combineLatest2 dari rxdart
      return Rx.combineLatest2<List<String>, QuerySnapshot,
          Either<Failure, List<Post>>>(
        blockedUserIdStream,
        postsStream,
        (excludedUserIds, snapshot) {
          try {
            // Filter posts berdasarkan excludedUserIds
            final filteredPosts = snapshot.docs
                .where((doc) => !excludedUserIds.contains(doc['uid']))
                .map((doc) => Post.fromDocument(doc))
                .toList();

            return Right(filteredPosts);
          } catch (e) {
            return Left(ServerFailure('Failed to parse posts: $e'));
          }
        },
      );
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to fetch posts: $e')));
    }
  }

  // Get individuaal posts
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

  // Get post by post id
  @override
  Stream<Either<Failure, Post>> getPost(String id) {
    try {
      return _db
          .collection('Posts')
          .doc(id)
          .snapshots()
          .map<Either<Failure, Post>>((snapshot) {
        final post = Post.fromDocument(snapshot);
        return Right(post);
      }).handleError((error) {
        return Left(ServerFailure('Failed to fetch posts: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to fetch posts: $e')));
    }
  }

  // Helper function to chunk the list into smaller batches of 10 IDs
  List<List<String>> _chunkList(List<String> list, int chunkSize) {
    List<List<String>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  Stream<List<Post>> _getPostsFromFollowing(
      List<String> followingUserIds) async* {
    if (followingUserIds.isEmpty) {
      yield [];
      return;
    }

    // Split the followingUserIds list into chunks of 10
    List<List<String>> userIdChunks = _chunkList(followingUserIds, 10);

    List<Post> allPosts = [];

    // Perform Firestore queries for each chunk and combine the results
    for (var chunk in userIdChunks) {
      var postsQuerySnapshot = await _db
          .collection('Posts')
          .where('uid', whereIn: chunk)
          .orderBy('timestamp',
              descending: true) // Sort by timestamp in descending order
          .get();

      List<Post> posts =
          postsQuerySnapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
      allPosts.addAll(posts);
    }

    // Sort the combined posts by timestamp in descending order (in case we get posts from multiple chunks)
    allPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Emit the combined and sorted list of posts
    yield allPosts;
  }

  // Combines the following stream and the post stream
  @override
  Stream<List<Post>> getFollowingPosts() {
    String currentUserId = _auth.currentUser!.uid;

    // Stream of blocked user IDs
    Stream<List<String>> blockedUserIdStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());

    // Stream of posts from the following users
    Stream<List<Post>> postsStream = getFollowing(currentUserId).asyncMap(
      (followingUserIds) {
        return _getPostsFromFollowing(
          followingUserIds.map(
            (following) {
              return following.uid;
            },
          ).toList(),
        ).first;
      },
    );

    // Combine the two streams to filter posts
    return Rx.combineLatest2<List<String>, List<Post>, List<Post>>(
      blockedUserIdStream,
      postsStream,
      (blockedUserIds, posts) {
        // Filter posts based on blocked user IDs
        return posts
            .where((post) => !blockedUserIds.contains(post.uid))
            .toList();
      },
    );
  }

  /*
    LIKES
  */

  // like a post
  @override
  Future<Either<Failure, Unit>> toggleLikeInFirebase(String postId) async {
    try {
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
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  /*
    COMMENTS
  */

  //Add a comment to a post
  @override
  Future<Either<Failure, Unit>> addComment(
      String postId, String message) async {
    try {
      String uid = _auth.currentUser!.uid;

      final resultUser = await getUserProfile(uid);

      if (resultUser.isLeft) {
        return Left(resultUser.leftOrNull()!);
      } else if (resultUser.isRight) {
        UserProfile? user = resultUser.rightOrNull();

        //create a new comment
        Comment newComment = Comment(
            id: '',
            postId: postId,
            uid: uid,
            name: user?.name ?? '',
            username: user?.username ?? '',
            message: message,
            timestamp: Timestamp.now());

        // convert comment object to map
        await _db.collection('Comments').add(newComment.toMap());

        //go to doc for this post
        DocumentReference postDoc = _db.collection('Posts').doc(postId);

        //update comment count
        await _db.runTransaction(
          (transaction) async {
            // get post data
            DocumentSnapshot postSnapshot = await transaction.get(postDoc);

            // get comment count
            int currentCommentCount = postSnapshot['commentCount'] ?? 0;

            currentCommentCount++;
            transaction.update(
              postDoc,
              {
                'commentCount': currentCommentCount,
              },
            );
          },
        );
        return const Right(unit);
      }

      return const Left(ServerFailure("Error getUserProfile"));
    } on FirebaseException catch (e) {
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  // Delete a comment
  @override
  Future<Either<Failure, Unit>> deleteComment(
      String postId, String commentId) async {
    log("delet");
    try {
      await _db.collection('Comments').doc(commentId).delete();

      //go to doc for this post
      DocumentReference postDoc = _db.collection('Posts').doc(postId);

      //update comment count
      await _db.runTransaction(
        (transaction) async {
          // get post data
          DocumentSnapshot postSnapshot = await transaction.get(postDoc);

          // get comment count
          int currentCommentCount = postSnapshot['commentCount'] ?? 0;
          currentCommentCount--;

          transaction.update(
            postDoc,
            {
              'commentCount': currentCommentCount,
            },
          );
        },
      );

      return const Right(unit);
    } on FirebaseException catch (e) {
      log("error $e");
      return Left(ServerFailure("Error getUserProfile ${e.code}"));
    } catch (e) {
      log("error deleteComment");
      return const Left(ServerFailure("Error deleteComment"));
    }
  }

  // Get all comments for a post
  @override
  Stream<Either<Failure, List<Comment>>> getPostComments(String postId) {
    try {
      return _db
          .collection('Comments')
          .where('postId', isEqualTo: postId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map<Either<Failure, List<Comment>>>((snapshot) {
        try {
          final comments =
              snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
          return Right(comments);
        } catch (e) {
          return Left(ServerFailure('Failed to parse posts: $e'));
        }
      }).handleError((error) {
        return Left(ServerFailure('Failed to fetch posts: $error'));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to fetch posts: $e')));
    }
  }

  /*
    ACCOUNT STUFF
  */

  //report post
  @override
  Future<void> reportUser(String postId, String userId) async {
    try {
      //get current user id
      final currentUserId = _auth.currentUser!.uid;

      //create a report map
      final report = {
        'reportedBy': currentUserId,
        'messageId': postId,
        'messageOwnerId': userId,
        'timeStamp': FieldValue.serverTimestamp()
      };

      //update in firestore
      await _db.collection('Reports').add(report);
    } catch (e) {
      log("error $e");
    }
  }

  //block user
  @override
  Future<void> blockUser(String userId) async {
    //get current user id
    final currentUserId = _auth.currentUser!.uid;

    //add this user to blocked list
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
  }

  // unblock user
  @override
  Future<void> unblockUser(String userId) async {
    //get current user id
    final currentUserId = _auth.currentUser!.uid;

    //add this user to blocked list
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(userId)
        .delete();
  }

  // get list of blocked user ids
  @override
  Stream<List<UserProfile>> getBlockedUids() {
    // Dapatkan current user id
    final currentUserId = _auth.currentUser!.uid;

    // Stream untuk mendapatkan blocked user IDs
    Stream<List<String>> blockedUidsStream = _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });

    // Menggunakan switchMap untuk menggabungkan blockedUids dengan UserProfile dari Users
    return blockedUidsStream.switchMap((blockedUids) {
      if (blockedUids.isEmpty) {
        return Stream.value([]);
      }

      // Menggabungkan UserProfile dari setiap blocked user ID
      final profileStreams = blockedUids.map((uid) {
        return _db.collection('Users').doc(uid).snapshots().map((snapshot) {
          if (snapshot.exists) {
            return UserProfile.fromDocument(snapshot);
          } else {
            return UserProfile(
                uid: uid,
                username: 'Unknown',
                email: 'Unknown',
                name: 'Unknown',
                bio: '');
          }
        });
      });

      // Menggunakan combineLatest untuk mendapatkan semua UserProfile sebagai satu stream
      return CombineLatestStream.list(profileStreams).map((profiles) {
        return profiles.cast<UserProfile>();
      });
    });
  }

  /*
    FOLLOW
  */

  //follow user
  @override
  Future<void> followUser(String targetUid) async {
    // get current logged in user
    try {
      final currentUserId = _auth.currentUser!.uid;
      DocumentSnapshot currentUserDoc =
          await _db.collection('Users').doc(currentUserId).get();
      final currentUser = UserProfile.fromDocument(currentUserDoc);

      // get target user
      DocumentSnapshot targetUserDoc =
          await _db.collection('Users').doc(targetUid).get();
      final targetUser = UserProfile.fromDocument(targetUserDoc);

      // add target user to the current user's following

      await _db
          .collection('Users')
          .doc(currentUserId)
          .collection('Following')
          .doc(targetUid)
          .set(
            Following(
              username: targetUser.username,
              uid: targetUid,
              name: targetUser.name,
            ).toMap(),
          );

      //add current user to target user's followers
      await _db
          .collection('Users')
          .doc(targetUid)
          .collection('Followers')
          .doc(currentUserId)
          .set(
            Following(
              username: currentUser.username,
              uid: currentUserId,
              name: currentUser.name,
            ).toMap(),
          );
    } catch (e) {
      log('error ${e.toString()}');
    }
  }

  //unfollow user
  @override
  Future<void> unfollowUser(String targetUid) async {
    // get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    // remove target user from the current user's following
    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(targetUid)
        .delete();

    //remove current user to target user's followers
    await _db
        .collection('Users')
        .doc(targetUid)
        .collection('Followers')
        .doc(currentUserId)
        .delete();
  }

  //get a user's followers: list of uids
  @override
  Stream<List<Following>> getFollowers(String uid) {
    try {
      return _db
          .collection('Users')
          .doc(uid)
          .collection('Followers')
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs
              .map(
                (doc) => Following.fromDocument(doc),
              )
              .toList();
        } catch (e) {
          return [];
        }
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  //get a user's following: list of uids
  @override
  Stream<List<Following>> getFollowing(String uid) {
    try {
      return _db
          .collection('Users')
          .doc(uid)
          .collection('Following')
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs
              .map(
                (doc) => Following.fromDocument(doc),
              )
              .toList();
        } catch (e) {
          return [];
        }
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  //check if current user already following target uid
  @override
  Stream<bool> isUserFollowed(String targetUid) {
    // get current logged in user
    final currentUserId = _auth.currentUser!.uid;

    return getFollowing(currentUserId).map((followingList) {
      return followingList.any((following) => following.uid == targetUid);
    });
  }

  /*
    SEARCH
  */

  // search for users by name
  Future<List<UserProfile>> searchUsers(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return snapshot.docs
          .map(
            (doc) => UserProfile.fromDocument(doc),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
