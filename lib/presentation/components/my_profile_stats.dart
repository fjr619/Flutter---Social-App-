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
  final Function()? onClicked;

  const MyProfileStats(
      {super.key, required this.count, required this.text, this.onClicked});

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = TextStyle(
        fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary);
    var textStyleForText =
        TextStyle(color: Theme.of(context).colorScheme.primary);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onClicked,
      child: SizedBox(
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
      ),
    );
  }
}
