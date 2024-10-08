import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_settings_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/theme_provider.dart';
import 'package:provider/provider.dart';

/*

SETTINGS PAGE

- dark mode
- blocked users
- account settings

*/

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //app bar
      appBar: AppBar(
        centerTitle: true,
        title: const Text("S E T T I N G S"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      //body
      body: Column(
        children: [
          // dark mode tile
          MySettingsTile(
            title: 'Dark Mode',
            action: CupertinoSwitch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toogleTheme(),
            ),
          ),

          // block users tile
          MySettingsTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => goBlockedUserPage(context),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // account settings tile
          MySettingsTile(
            title: 'Account Settings',
            action: IconButton(
              onPressed: () => goAccountSettingsPage(context),
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
