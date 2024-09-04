/*

  USER LIST TILE

  This is to display each user as a nice tile.
  We will use this when we need to display a list of users.

  _________________________

  To use this widget, you need:
  - name,
  - username,
  - onTap

*/

import 'package:flutter/material.dart';

class MyUserTile extends StatelessWidget {
  final String name;
  final String username;
  final Function()? onTap;

  const MyUserTile(
      {super.key,
      required this.name,
      required this.username,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text(name),
            subtitle: Text('@$username'),
            subtitleTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.primary),
            leading: Icon(
              Icons.person_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            trailing: Icon(
              size: 16,
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
