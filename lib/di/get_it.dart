import 'package:flutter_twitter_clone/themes/theme_provider.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  //Providers
  getIt.registerLazySingleton(() => ThemeProvider());
}
