import 'package:flutter/material.dart';

/*

SETTINGS LIST TILE

This is a simple tile for each item in the settings page

__________________________

To use this widget, you need:

- title
- action

*/

class MySettingsTile extends StatelessWidget {
  final String title;
  final Widget action;
  const MySettingsTile({super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    // container
    return Container(
      decoration: BoxDecoration(
          //color
          color: Theme.of(context).colorScheme.secondary,

          //curve corners
          borderRadius: BorderRadius.circular(12)),

      // padding outside
      margin: const EdgeInsets.only(left: 25, right: 25, top: 10),

      // padding inside
      padding: const EdgeInsets.all(25),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          action,
        ],
      ),
    );
  }
}
