/*

COMMENT FILE

This is the comment file widget which belongs below a post, 
It's similar to the post tile widget, 
but let's make the comments look slightly different to post

_____________________

To use this widget, you need:

- the comment
- function

*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_twitter_clone/domain/model/comment.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyCommentTile extends StatefulWidget {
  const MyCommentTile({super.key, required this.comment, this.onUserTap});
  final Comment comment;
  final Function()? onUserTap;

  @override
  State<MyCommentTile> createState() => _MyCommentTileState();
}

class _MyCommentTileState extends State<MyCommentTile> {
  void _showOptions() {
    //check if this post in owned by the user or not
    String currentUid = context.read<AuthenticationProvider>().currentUser!.uid;
    final bool isOwnPost = widget.comment.uid == currentUid;

    deleteComment(BuildContext context) async {
      context.pop();
      await context
          .read<DatabaseProvider>()
          .deleteComment(widget.comment.postId, widget.comment.id);
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
                      onTap: () => deleteComment(context),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      // padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          widget.comment.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Gap(5),

                        // profile username
                        Text(
                          '@${widget.comment.username}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    onPressed: _showOptions,
                    icon: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ))
              ],
            ),
          ),

          //message
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 10),
            child: Text(
              widget.comment.message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }
}
