import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/presentation/components/my_drawer.dart';
import 'package:flutter_twitter_clone/presentation/components/my_input_alert_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_loading.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/*

  HOME PAGE

  This is the main page of this app. It displays a list of all posts.

 */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controller
  final _messageController = TextEditingController();

  //show post message dialog box
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: _messageController,
          hint: 'What\'s on your mind?',
          onPressed: () async {
            await postMessage(_messageController.text);
          },
          onPressedText: 'Post'),
    );
  }

  //post message
  Future<void> postMessage(String message) async {
    await context.read<DatabaseProvider>().postMessage(message);
  }

  // //load all posts
  // Future<void> loadAllPosts() async {
  //   context.read<DatabaseProvider>().loadAllPosts();
  // }

  //on startup
  @override
  void initState() {
    super.initState();

    // // let's load all posts
    // loadAllPosts();
  }

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

      //drawer
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

      //appbar
      appBar: AppBar(
        centerTitle: true,
        title: const Text('H O M E'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //floating button
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.add),
      ),

      //body
      body: StreamBuilder(
        stream: context.watch<DatabaseProvider>().loadAllPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return !snapshot.hasData
                ? const Center(
                    child: Text('Nothing here'),
                  )
                : snapshot.data!.fold((failure) {
                    return Center(
                      child: Text('Error here ${failure.message}'),
                    );
                  }, (data) {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final post = data[index];
                        return MyPostTile(post: post);
                      },
                    );
                  });
          }
        },
      ),
    );
  }
}
