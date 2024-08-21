import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/presentation/components/my_bio_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_input_alert_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //text controller for bio
  final bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        databaseProvider.showDialog();
        await databaseProvider.getUserProfile(widget.uid);
      } finally {
        databaseProvider.hideDialog();
      }
    });
  }

  // show edit bio box
  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: bioController,
            hint: 'Edit bio',
            onPressed: saveBio,
            onPressedText: 'Save'));
  }

  // save user bio
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
        title: Text(databaseProvider.isLoading
            ? ''
            : databaseProvider.userProfile?.name ?? 'User Profile'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          //username handle
          Center(
            child: Text(
              databaseProvider.isLoading
                  ? ''
                  : '@${databaseProvider.userProfile?.username ?? ''}',
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
                IconButton(
                  onPressed: _showEditBioBox,
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          //bio box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MyBioBox(
                text: (databaseProvider.isLoading)
                    ? '...'
                    : databaseProvider.userProfile?.bio ?? 'Empty bio'),
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
            child: FutureBuilder<List<Post>>(
              future: databaseProvider.getUserPosts(widget.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No posts found'));
                } else {
                  final posts = snapshot.data!;
                  log("data ${posts.length}");

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return MyPostTile(post: posts[index]);
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
