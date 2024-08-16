/*

REGIISTER PAGE

On this page, a new user can fill out the form and create an account.
The data we want from the user is:

- name
- email,
- password,
- confirm password

__________________________________

Once the user successfully creates an account -> they will be redirected to home page.

Also, if user already has an account, they can go to page from here.

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/presentation/components/my_button.dart';
import 'package:flutter_twitter_clone/presentation/components/my_textfield.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Gap(50),
                //Logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const Gap(50),

                // create an account message
                Text(
                  "Let's create an account for you",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),

                const Gap(25),

                //name textfield
                MyTextfield(
                    textEditingController: nameController,
                    hintText: 'Enter name',
                    obscureText: false),

                const Gap(10),

                //email textfield
                MyTextfield(
                    textEditingController: emailController,
                    hintText: 'Enter email',
                    obscureText: false),

                const Gap(10),

                //password textfield
                MyTextfield(
                    textEditingController: passwordController,
                    hintText: 'Enter password',
                    obscureText: true),

                const Gap(10),

                //password textfield
                MyTextfield(
                    textEditingController: confirmPasswordController,
                    hintText: 'Enter confirm password',
                    obscureText: true),

                const Gap(25),

                //register button
                MyButton(
                  text: 'Register',
                  onClick: () {},
                ),

                const Gap(50),

                // already a member? login here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const Gap(5),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        context.goNamed(AppRoute.login);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          'Login now',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
