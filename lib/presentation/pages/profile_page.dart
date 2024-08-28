import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_bio_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_input_alert_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DatabaseProvider(),
      child: ProfilePageContent(
        uid: uid,
      ),
    );
  }
}

class ProfilePageContent extends StatefulWidget {
  final String uid;

  const ProfilePageContent({super.key, required this.uid});

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  late final DatabaseProvider databaseProvider =
      Provider.of(context, listen: false);
  late final AuthenticationProvider authProvider =
      Provider.of(context, listen: false);
  late final DatabaseProvider listenDatabaseProvider = Provider.of(context);
  final bioController = TextEditingController();
  late Stream<Either<Failure, List<Post>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = databaseProvider.getUserPosts(widget.uid);
    loadUser();
  }

  @override
  void dispose() {
    super.dispose();
    bioController.dispose;
    log('profile page dispose');
  }

  void loadUser() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final databaseProvider =
            Provider.of<DatabaseProvider>(context, listen: false);
        databaseProvider.showDialog();
        await databaseProvider.getUserProfile(widget.uid);
      } finally {
        databaseProvider.hideDialog();
      }
    });
  }

  // // show edit bio box
  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: bioController,
            hint: 'Edit bio',
            onPressed: saveBio,
            onPressedText: 'Save'));
  }

  // // save user bio
  Future<void> saveBio() async {
    databaseProvider.showDialog();
    await databaseProvider.updateUserBio(bioController.text);
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(listenDatabaseProvider.isLoading
            ? ''
            : listenDatabaseProvider.userProfile?.name ?? 'User Profile'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          //username handle
          Center(
            child: Text(
              listenDatabaseProvider.isLoading
                  ? ''
                  : '@${listenDatabaseProvider.userProfile?.username ?? ''}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),

          const Gap(25),

          //profile picture
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(25),
              child: Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const Gap(25),

          //profile stats -> number of post / followers / following

          //follow / unfollow button

          // edit bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bio',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16),
                ),
                if (widget.uid == authProvider.currentUser?.uid) ...{
                  IconButton(
                    onPressed: _showEditBioBox,
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                },
              ],
            ),
          ),

          //bio box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MyBioBox(
                text: (listenDatabaseProvider.isLoading)
                    ? '...'
                    : listenDatabaseProvider.userProfile?.bio ?? 'Empty bio'),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Posts',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ),

          //list of post from user
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StreamBuilder(
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
                          log('data ${data.length}');
                          if (data.isEmpty) {
                            return const Center(
                              child: Text('Nothing here'),
                            );
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final post = data[index];
                              return MyPostTile(
                                post: post,
                                onUserTap: () => null,
                                onPostTap: () => goPostPage(context, post),
                              );
                            },
                          );
                        });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
