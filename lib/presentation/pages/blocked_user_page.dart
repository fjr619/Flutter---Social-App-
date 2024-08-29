import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BlockedUserPage extends StatefulWidget {
  const BlockedUserPage({super.key});

  @override
  State<BlockedUserPage> createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  late final DatabaseProvider databaseProvider =
      Provider.of(context, listen: false);
  late final DatabaseProvider listenDatabaseProvider = Provider.of(context);
  late Stream<List<UserProfile>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = databaseProvider.getBlockedUids();
  }

  void _showSuccessSnackbar(bool needPop, String message) {
    if (needPop) context.pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  void _showUnblockConfirmation(String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: const Text('Are you use want to unblock this user?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await databaseProvider.unblockUser(uid);
              _showSuccessSnackbar(true, 'User unblocked');
            },
            child: Text(
              'Unblock',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('B L O C K E D  U S E R'),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return !snapshot.hasData
                ? const Center(
                    child: Text('No blocked users'),
                  )
                : snapshot.data?.isEmpty == true
                    ? const Center(
                        child: Text('No blocked users'),
                      )
                    : ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data?[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              tileColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                '${user?.name}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary),
                              ),
                              subtitle: Text(
                                '@${user?.username}',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              trailing: IconButton(
                                onPressed: () =>
                                    _showUnblockConfirmation(user!.uid),
                                icon: Icon(
                                  Icons.block,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      );
          }
        },
      ),
    );
  }
}
