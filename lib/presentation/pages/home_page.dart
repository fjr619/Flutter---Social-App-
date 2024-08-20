import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/presentation/components/my_drawer.dart';
import 'package:flutter_twitter_clone/presentation/components/my_loading.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    void logout() async {
      //show loading
      showLoadingCircle(context);

      try {
        // trying to login
        await context.read<AuthenticationProvider>().logout();

        // finished loading
        if (context.mounted) hideLoadingCircle(context);

        // catch any errors
      } catch (e) {
        // finished loading
        if (context.mounted) hideLoadingCircle(context);
        log("error $e");
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(
        onClickHome: () => context.pop(),
        onClickProfile: () {
          log('uid ${context.read<AuthenticationProvider>().currentUser?.uid}');
          context.pop();
          context.pushNamed(AppRoute.profile, pathParameters: {
            'uid': context.read<AuthenticationProvider>().currentUser!.uid
          });
        },
        onClickSettings: () {
          context.pop();
          context.pushNamed(AppRoute.settings);
        },
        onClickLogout: logout,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('H O M E'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
