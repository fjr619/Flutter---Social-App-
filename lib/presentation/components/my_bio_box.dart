import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
 USER BIO BOX
 
 This is a simple box with text inside. We will use this for the user bio on their profile pages.

 To use this widget, you just need:

 - text
*/

class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //color
        color: Theme.of(context).colorScheme.secondary,

        //curve corners
        borderRadius: BorderRadius.circular(8),
      ),

      //padding inside
      padding: const EdgeInsets.all(25),

      //text
      child: Text(
        text.isNotEmpty ? text : 'Empty bio..',
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
