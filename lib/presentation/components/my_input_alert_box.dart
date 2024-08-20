import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/*

  INPUT ALERT BOX

  This is an alert dialog box that has a textfield where the user can type in.
  We will use this for things like editing bio, posting a new message, etc.

  ______________________________

  To use this widget, you need:

  - text controller
  - hint text
  - function
  - text for button

*/

class MyInputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hint;
  final Function() onPressed;
  final String onPressedText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hint,
    required this.onPressed,
    required this.onPressedText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //curve corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),

      //color
      backgroundColor: Theme.of(context).colorScheme.surface,

      content: TextField(
        controller: textController,

        //limit the max characters
        maxLength: 140,
        maxLines: 3,
        decoration: InputDecoration(
          //border when textfield is unseleccted
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),

          //border when textfield is selected
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(12),
          ),

          //hint text
          hintText: hint,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),

          //color inside of textfield
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,

          //counter style
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),

      // buttons
      actions: [
        //cancel button
        TextButton(
          onPressed: () {
            //close box
            context.pop();

            //clear controller
            textController.clear();
          },
          child: const Text('Cancel'),
        ),

        //yes button
        TextButton(
          onPressed: () {
            //close box
            context.pop();

            //execute
            onPressed();

            //clear controller
            textController.clear();
          },
          child: Text(
            onPressedText,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ),
      ],
    );
  }
}
