import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      routerConfig: router,
    );
  }
}
