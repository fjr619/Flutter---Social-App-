/*

BUTTON

A simple button

_____________________________

To use this widget, you need:

- text
- function

*/

import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function() onClick;
  const MyButton({super.key, required this.text, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          elevation: 0,
          shadowColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onClick,
        child: Text(text),
      ),
    );
  }
}
