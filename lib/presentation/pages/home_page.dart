import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/presentation/components/my_drawer.dart';
import 'package:flutter_twitter_clone/presentation/components/my_input_alert_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_loading.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tab_list.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

/*

  HOME PAGE

  This is the main page of this app. It displays a list of all posts.

  ___________________________

  We can organise this page using a tab bar to split into :
  - for you page
  - following page

 */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final DatabaseProvider databaseProvider =
      Provider.of(context, listen: false);
  late TabController _tabController;

  // BehaviorSubjects to manage streams
  late final BehaviorSubject<Either<Failure, List<Post>>> _allPostsSubject;
  late final BehaviorSubject<List<Post>> _followingPostsSubject;

  //text controller
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize BehaviorSubjects with an initial empty list
    _allPostsSubject =
        BehaviorSubject<Either<Failure, List<Post>>>.seeded(const Right([]));
    _followingPostsSubject = BehaviorSubject<List<Post>>.seeded([]);

    // Listen to the database streams and add data to the BehaviorSubjects
    databaseProvider.loadAllPosts().listen((data) {
      _allPostsSubject.add(data);
    });

    databaseProvider.getFollowingPosts().listen((data) {
      _followingPostsSubject.add(data);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _tabController = TabController(length: 2, vsync: this);
    _allPostsSubject.close();
    _followingPostsSubject.close();
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

  Widget _buildAllPost() {
    return StreamBuilder(
      stream: _allPostsSubject.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          // Handle unexpected errors
          return Center(
            child: Text('Something went wrong: ${snapshot.error}'),
          );
        }

        return !snapshot.hasData
            ? const Center(
                child: Text('Nothing here'),
              )
            : snapshot.data!.fold((failure) {
                return Center(
                  child: Text('Error here ${failure.message}'),
                );
              }, (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text('Nothing here'),
                  );
                }
                return MyPostTabList(posts: posts);
              });
      },
    );
  }

  Widget _buildFollowingPost() {
    return StreamBuilder<List<Post>>(
      stream: _followingPostsSubject.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading posts'));
        }

        final posts = snapshot.data;

        if (posts == null || posts.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        return MyPostTabList(posts: posts);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        //drawer
        drawer: MyDrawer(
          onClickHome: () => context.pop(),
          onClickProfile: () {
            context.pop();
            goUserPage(context,
                context.read<AuthenticationProvider>().currentUser!.uid);
          },
          onClickSearch: () {
            context.pop();
            goSearchPage(context);
          },
          onClickSettings: () {
            context.pop();
            goSettingPage(context);
          },
          onClickLogout: logout,
        ),

        //appbar
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text('H O M E'),
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(
                text: 'For you',
              ),
              Tab(
                text: 'Following',
              ),
            ],
          ),
        ),

        //floating button
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          highlightElevation: 0,
          onPressed: _openPostMessageBox,
          child: const Icon(Icons.add),
        ),

        //body
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllPost(),
              _buildFollowingPost(),
            ],
          ),
        ),
      ),
    );
  }
}
