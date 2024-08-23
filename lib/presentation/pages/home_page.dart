import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
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
  late final DatabaseProvider databaseProvider =
      Provider.of(context, listen: false);
  late Stream<Either<Failure, List<Post>>> _stream;
  //text controller
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stream = databaseProvider.loadAllPosts();
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

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

  //logout
  void logout() async {
    //show loading
    showLoadingCircle(context);

    try {
      // trying to login
      await context.read<AuthenticationProvider>().logout();

      // finished loading
      if (mounted) hideLoadingCircle(context);

      // catch any errors
    } catch (e) {
      // finished loading
      if (mounted) hideLoadingCircle(context);
      log("error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //drawer
      drawer: MyDrawer(
        onClickHome: () => context.pop(),
        onClickProfile: () {
          context.pop();
          goUserPage(
              context, context.read<AuthenticationProvider>().currentUser!.uid);
        },
        onClickSettings: () {
          context.pop();
          context.pushNamed(AppRoute.settings);
        },
        onClickLogout: logout,
      ),

      //appbar
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
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
        stream: _stream,
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
                    if (data.isEmpty) {
                      return const Center(
                        child: Text('Nothing here'),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final post = data[index];
                        return MyPostTile(
                          post: post,
                          onUserTap: () => goUserPage(context, post.uid),
                          onPostTap: () => goPostPage(context, post),
                        );
                      },
                    );
                  });
          }
        },
      ),
    );
  }
}
