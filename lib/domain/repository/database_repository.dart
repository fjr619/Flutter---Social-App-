import 'package:eitherx/eitherx.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';

abstract class DatabaseRepository {
  Future<Either<Failure, Unit>> saveUserProfile(
      {required String name, required String email});
  Future<Either<Failure, UserProfile?>> getUserProfile(String uid);
}
