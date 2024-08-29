/*

  FOLLOW BUTTON

  This is a follow / unfollow button, depending on whose profile page we are currently viewing.
   
   ____________________

   To use this widget, you need:
   - function
   - isFollowing

*/

import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final Function()? onPressed;
  final bool isFollowing;

  const MyFollowButton(
      {super.key, required this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: onPressed,
        padding: const EdgeInsets.all(25),
        color:
            isFollowing ? Theme.of(context).colorScheme.primary : Colors.green,
        elevation: 0,
        highlightElevation: 0,
        child: Text(
          isFollowing ? 'Unfollow' : 'Follow',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
