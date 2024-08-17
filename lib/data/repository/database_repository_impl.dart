import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eitherx/eitherx.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
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

  /* user profile
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
    } catch (e) {
      return const Left(ServerFailure("Error getUserProfile"));
    }
  }

  /**
   * 
   */
}
