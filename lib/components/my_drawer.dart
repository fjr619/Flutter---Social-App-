/*

DRAWER

This is a menu drawer which is usually access on the left side of the app bar

______

Contains 5 menu options:

- Home
- Profile
- Search
- Settings
- Logout

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/components/my_drawer_tile.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              //app logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),

              const Gap(10),

              // home
              MyDrawerTile(
                title: 'H O M E',
                icon: Icons.home,
                onClick: () {
                  //pop menu drawer since we are already at home
                  context.pop();
                },
              ),

              // profile
              MyDrawerTile(
                title: 'P R O F I L E',
                icon: Icons.person_2,
                onClick: () {},
              ),

              // search
              MyDrawerTile(
                title: 'S E A R C H',
                icon: Icons.search_outlined,
                onClick: () {},
              ),

              // settings
              MyDrawerTile(
                title: 'S E T T I N G S',
                icon: Icons.settings,
                onClick: () {
                  //pop menu drawer
                  context.pop();

                  //go to settings page
                  GoRouter.of(context).pushNamed('Settings');
                  // context.pushNamed('Settings');
                },
              ),

              // logout
              MyDrawerTile(
                title: 'L O G O U T',
                icon: Icons.logout,
                onClick: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
