import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/components/my_button.dart';
import 'package:flutter_twitter_clone/components/my_textfield.dart';
import 'package:flutter_twitter_clone/di/get_it.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/service/auth_service.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/*

LOGIN PAGE

On this page, an existing user can log in with their: 

- email
- password

_____________

Once the user successfully logs in, they will be redirected to the home page.

If the user doesn't have an account yet, they can go to the register page from here.

*/

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final authService = getIt<AuthService>();

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

                //Welcome back message
                Text(
                  'Welcome back, you\'ve been missed!',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),

                const Gap(25),

                //email textfield
                MyTextfield(
                    textEditingController: emailController,
                    hintText: 'Enter Email',
                    obscureText: false),

                const Gap(10),

                //password textfield
                MyTextfield(
                    textEditingController: passwordController,
                    hintText: 'Enter password',
                    obscureText: true),

                const Gap(10),

                //forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        'Forgot password',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const Gap(25),

                //sign in button
                MyButton(
                  text: 'Login',
                  onClick: () async {
                    try {
                      await authService.loginEmailPassword(
                          emailController.text, passwordController.text);
                    } catch (e) {
                      log("error $e");
                    }
                  },
                ),

                const Gap(50),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const Gap(5),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        context.pushReplacementNamed(AppRoute.register);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          'Register now',
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
