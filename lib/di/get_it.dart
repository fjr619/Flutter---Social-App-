import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_clone/data/repository/auth_repository_impl.dart';
import 'package:flutter_twitter_clone/domain/repository/auth_repository.dart';
import 'package:flutter_twitter_clone/service/auth_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Register FirebaseAuth
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register Repositories
  getIt
      .registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
}
