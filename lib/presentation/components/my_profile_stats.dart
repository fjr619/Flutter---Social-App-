/*

  PROFILE STATS

  This will be displayed on the profile page

  ___________________

  numbers of
  - posts
  - followers
  - following

*/

import 'package:flutter/material.dart';

class MyProfileStats extends StatelessWidget {
  final String count;
  final String text;

  const MyProfileStats({super.key, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = TextStyle(
        fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary);
    var textStyleForText =
        TextStyle(color: Theme.of(context).colorScheme.primary);
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Text(
            count,
            style: textStyleForCount,
          ),
          Text(
            text,
            style: textStyleForText,
          )
        ],
      ),
    );
  }
}
