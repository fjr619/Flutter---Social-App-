/*

  FOLLOW LIST PAGE

  This page displays a tab for 

  - a list of all followers
  - a list of all following

*/

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/following.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_user_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:provider/provider.dart';

class FollowListPage extends StatefulWidget {
  final String userName;
  final String uid;
  final bool isFollowingTab;
  const FollowListPage(
      {super.key,
      required this.uid,
      required this.userName,
      required this.isFollowingTab});

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  // Using streams to load and cache data
  late final Stream<List<Following>> _followersStream;
  late final Stream<List<Following>> _followingStream;
  late final DatabaseProvider databaseProvider = Provider.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize streams that will automatically handle data loading
    _followersStream = databaseProvider.getFollowers(widget.uid);
    _followingStream = databaseProvider.getFollowing(widget.uid);
  }

  Widget _buildFollowersTab() {
    return StreamBuilder<List<Following>>(
      stream: _followersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading followers'));
        }

        final followers = snapshot.data;

        if (followers == null || followers.isEmpty) {
          return const Center(child: Text('No followers found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          shrinkWrap: true,
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final user = followers[index];
            return MyUserTile(
              name: user.name,
              username: user.username,
              onTap: () => goUserPage(context, user.uid),
            );
          },
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return StreamBuilder<List<Following>>(
      stream: _followingStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading followers'));
        }

        final following = snapshot.data;

        if (following == null || following.isEmpty) {
          return const Center(child: Text('No following found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          itemCount: following.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final user = following[index];
            return MyUserTile(
              name: user.name,
              username: user.username,
              onTap: () => goUserPage(context, user.uid),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.isFollowingTab ? 1 : 0,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text('@${widget.userName}'),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(
                text: 'Followers',
              ),
              Tab(
                text: 'Following',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFollowersTab(),
            _buildFollowingTab(),
          ],
        ),
      ),
    );
  }
}
