/*

  POST PAGE

  This page displays:

  - individual post
  - comments on this post

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tile.dart';

class PostPage extends StatelessWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          //post
          MyPostTile(
              post: post,
              onUserTap: () => goUserPage(context, post.uid),
              onPostTap: null),
        ],
      ),
    );
  }
}
