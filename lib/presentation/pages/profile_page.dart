import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/presentation/components/my_bio_box.dart';
import 'package:flutter_twitter_clone/presentation/components/my_input_alert_box.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //text controller for bio
  final bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DatabaseProvider>().showDialog();
    loadUser();
  }

  void loadUser() async {
    // Fetch data when the widget is first created
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await context.read<DatabaseProvider>().getUserProfile(widget.uid);
    //   context.read<DatabaseProvider>().hideDialog();
    // });

    await context.read<DatabaseProvider>().getUserProfile(widget.uid);
    if (mounted) context.read<DatabaseProvider>().hideDialog();
  }

  // show edit bio box
  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: bioController,
            hint: 'Edit bio',
            onPressed: saveBio,
            onPressedText: 'Save'));
  }

  // save user bio
  Future<void> saveBio() async {
    context.read<DatabaseProvider>().showDialog();
    await context.read<DatabaseProvider>().updateUserBio(bioController.text);
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = context.watch<DatabaseProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(databaseProvider.isLoading
            ? ''
            : databaseProvider.userProfile!.name),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [
            //username handle
            Center(
              child: Text(
                databaseProvider.isLoading
                    ? ''
                    : '@${databaseProvider.userProfile!.username}',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),

            const Gap(25),

            //profile picture
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(25),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const Gap(25),

            //profile stats -> number of post / followers / following

            //follow / unfollow button

            // edit bio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bio',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16),
                ),
                IconButton(
                  onPressed: _showEditBioBox,
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            const Gap(0),

            //bio box
            MyBioBox(
                text: (databaseProvider.isLoading)
                    ? '...'
                    : databaseProvider.userProfile!.bio),

            //list of post from user
          ],
        ),
      ),
    );
  }
}
