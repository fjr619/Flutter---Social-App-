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
import 'package:flutter_twitter_clone/presentation/components/my_loading.dart';
import 'package:flutter_twitter_clone/presentation/components/my_textfield.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthenticationProvider(),
      child: const RegisterPageContainer(),
    );
  }
}

class RegisterPageContainer extends StatefulWidget {
  const RegisterPageContainer({super.key});

  @override
  State<RegisterPageContainer> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPageContainer> {
  //text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final firestoreProvider = Provider.of<DatabaseProvider>(context);

    //register
    void register() async {
      //password match -> create user
      if (passwordController.text == confirmPasswordController.text) {
        bool isSucceed = await authProvider.register(
            emailController.text, passwordController.text);

        if (isSucceed) {
          await firestoreProvider.saveUserProfile(
              name: nameController.text, email: emailController.text);
        }
      }

      //password didnt math -> show error
      else {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Passwords don't match!"),
            );
          },
        );
      }
    }

    return Consumer<AuthenticationProvider>(
      builder: (context, value, child) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (authProvider.isLoading || firestoreProvider.isLoading) {
            if (context.canPop()) context.pop();
            showLoadingCircle(context);
          } else if (authProvider.errorMessage?.isNotEmpty == true) {
            if (context.canPop()) context.pop();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("ERROR ${authProvider.errorMessage}"),
              ),
            );
          } else {
            if (context.canPop()) context.pop();
          }
        });

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
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
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
                      onClick: register,
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
      },
    );
  }
}
