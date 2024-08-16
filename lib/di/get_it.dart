import 'package:flutter_twitter_clone/service/auth_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // getIt.registerLazySingleton(() => ThemeProvider());
  getIt.registerLazySingleton(
    () => AuthService(),
  );
}
