/*

  POST TILE

  All posts will be displayed using this tile widget
  
  ______

  To use this widget, you need:

  - post

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:gap/gap.dart';

class MyPostTile extends StatelessWidget {
  final Post post;

  const MyPostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding outside
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      //padding inside
      padding: const EdgeInsets.all(20),

      //box decoration
      decoration: BoxDecoration(
          //color of post tile
          color: Theme.of(context).colorScheme.secondary,

          //curve corners
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //top section profile pic / name / username
          Row(
            children: [
              // profile pic
              Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),

              const Gap(10),

              // profile name
              Text(
                post.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Gap(5),

              // profile username
              Text(
                '@${post.username}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              )
            ],
          ),

          const Gap(20),

          //message
          Text(
            post.message,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          )
        ],
      ),
    );
  }
}
