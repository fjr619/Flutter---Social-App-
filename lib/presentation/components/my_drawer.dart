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
import 'package:flutter_twitter_clone/presentation/components/my_drawer_tile.dart';
import 'package:gap/gap.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer(
      {super.key,
      required this.onClickHome,
      required this.onClickProfile,
      required this.onClickSettings,
      required this.onClickLogout,
      required this.onClickSearch});

  final Function() onClickHome;
  final Function() onClickProfile;
  final Function() onClickSettings;
  final Function() onClickLogout;
  final Function() onClickSearch;

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
                onClick: onClickHome,
              ),

              // profile
              MyDrawerTile(
                title: 'P R O F I L E',
                icon: Icons.person_2,
                onClick: onClickProfile,
              ),

              // search
              MyDrawerTile(
                title: 'S E A R C H',
                icon: Icons.search_outlined,
                onClick: onClickSearch,
              ),

              // settings
              MyDrawerTile(
                title: 'S E T T I N G S',
                icon: Icons.settings,
                onClick: onClickSettings,
              ),

              const Spacer(),

              // logout
              MyDrawerTile(
                title: 'L O G O U T',
                icon: Icons.logout,
                onClick: onClickLogout,
              ),

              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
