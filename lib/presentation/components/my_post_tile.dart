/*

  POST TILE

  All posts will be displayed using this tile widget
  
  ______

  To use this widget, you need:

  - post
  - function for onPostTap
  - function for onUserTap

*/

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/presentation/components/my_input_alert_box.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final Function()? onUserTap;
  final Function()? onPostTap;

  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _commentController.dispose();
  }

  void _openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
          textController: _commentController,
          hint: 'Type a comment',
          onPressed: () async {
            if (_commentController.text.trim().isEmpty) return;

            context
                .read<DatabaseProvider>()
                .postComment(_commentController.text, widget.post);
          },
          onPressedText: 'Submit'),
    );
  }

  void _showOptions(BuildContext context) {
    //check if this post in owned by the user or not
    String currentUid =
        context.read<AuthenticationProvider>().currentUser?.uid ?? '';
    final bool isOwnPost = widget.post.uid == currentUid;

    deletePost(BuildContext context) async {
      context.pop();
      await context.read<DatabaseProvider>().deletePost(widget.post.id);
    }

    reportUser(BuildContext context) {
      context.pop();
    }

    blockUser(BuildContext context) {
      context.pop();
    }

    //show options
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // this post belongs to current user
              if (isOwnPost) ...{
                //delete message button
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => deletePost(context),
                      child: const ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(20))),
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                  ),
                )

                //this post does not belong to user
              } else ...{
                //report post button
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => reportUser(context),
                      child: const ListTile(
                        leading: Icon(Icons.flag),
                        title: Text('Report'),
                      ),
                    ),
                  ),
                ),
                //blockl
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block'),
                  onTap: () => blockUser(context),
                ),
              },

              //cancel button
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  context.pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onPostTap,
        child: Ink(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //top section profile pic / name / username
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      onTap: widget.onUserTap,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // profile pic
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),

                            const Gap(10),

                            // profile name
                            Text(
                              widget.post.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Gap(5),

                            // profile username
                            Text(
                              '@${widget.post.username}',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () => _showOptions(context),
                        icon: Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).colorScheme.primary,
                        ))
                  ],
                ),
              ),

              //message
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Text(
                  widget.post.message,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),

              Row(children: [
                SizedBox(
                  width: 80,

                  // like
                  child: Row(
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(
                            maxHeight: 30,
                            minHeight: 30,
                            maxWidth: 30,
                            minWidth: 30),
                        onPressed: () async {
                          await context
                              .read<DatabaseProvider>()
                              .likePost(widget.post.id);
                        },
                        icon: AnimatedCrossFade(
                          firstChild: Icon(
                            Icons.favorite_border,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                            key: const ValueKey('notLiked'),
                          ),
                          secondChild: Icon(
                            Icons.favorite,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                            key: const ValueKey('liked'),
                          ),
                          crossFadeState: widget.post.likedBy.contains(context
                                      .watch<AuthenticationProvider>()
                                      .currentUser
                                      ?.uid ??
                                  '')
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          layoutBuilder: (topChild, topChildKey, bottomChild,
                              bottomChildKey) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Positioned(
                                    key: bottomChildKey, child: bottomChild),
                                Positioned(key: topChildKey, child: topChild),
                              ],
                            );
                          },
                          duration: const Duration(milliseconds: 400),
                        ),
                      ),
                      Text(
                        context
                            .watch<DatabaseProvider>()
                            .formatNumber(widget.post.likeCount),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // comment
                Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(
                          maxHeight: 30,
                          minHeight: 30,
                          maxWidth: 30,
                          minWidth: 30),
                      onPressed: _openNewCommentBox,
                      icon: Icon(
                        Icons.comment,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      context
                          .watch<DatabaseProvider>()
                          .formatNumber(widget.post.commentCount),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12),
                    ),
                  ],
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
