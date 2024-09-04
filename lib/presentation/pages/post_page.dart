/*

  POST PAGE

  This page displays:

  - individual post
  - comments on this post

*/

import 'dart:developer';

import 'package:eitherx/eitherx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/comment.dart';
import 'package:flutter_twitter_clone/domain/model/failure.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_comment_tile.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final DatabaseProvider databaseProvider =
      Provider.of(context, listen: false);
  late Stream<Either<Failure, Post>> _stream;
  late Stream<Either<Failure, List<Comment>>> _streamComment;

  @override
  void initState() {
    super.initState();
    _stream = databaseProvider.getPost(widget.post.id);
    _streamComment = databaseProvider.loadPostComments(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('P O S T'),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          //post
          StreamBuilder(
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
                      }, (post) {
                        return MyPostTile(
                          post: post,
                          onUserTap: () => goUserPage(context, post.uid),
                          onPostTap: () => null,
                          doAfterDelete: () => context.pop(),
                        );
                      });
              }
            },
          ),

          //all comments
          StreamBuilder(
            stream: _streamComment,
            builder: (context, snapshot) {
              log('snapshot.connectionState ${snapshot.connectionState}');
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
                    }, (data) {
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
                          final comment = data[index];
                          return MyCommentTile(
                            comment: comment,
                            onUserTap: () => goUserPage(context, comment.uid),
                          );
                        },
                      );
                    });
            },
          )
        ],
      ),
    );
  }
}
