import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/user_profile.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_user_tile.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  late final databaseProvider = Provider.of<DatabaseProvider>(context);
  final _searchSubject = PublishSubject<String>();
  Future<List<UserProfile>>? _searchResults;

  @override
  void initState() {
    super.initState();

    // Listen to the search input stream with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 500)) // Add 500ms debounce
        .listen((searchTerm) {
      if (searchTerm.length >= 3) {
        setState(() {
          // Trigger search only if input has at least 3 characters
          _searchResults =
              context.read<DatabaseProvider>().searchUsers(searchTerm);
        });
      } else {
        // Clear search results if input is less than 3 characters
        setState(() {
          _searchResults = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close(); // Close the stream when disposing
    super.dispose();
  }

  // Trigger search when user types something
  void _onSearchChanged(String value) {
    _searchSubject.add(value); // Add the search term to the subject
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
              hintText: 'Search users..',
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none),

          //search will begin after each new character has been type
          onChanged: _onSearchChanged,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _searchResults == null
          ? const Center(
              child: Text('Enter a name to search'),
            )
          : FutureBuilder<List<UserProfile>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final users = snapshot.data;
                if (users == null || users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return MyUserTile(
                      name: user.name,
                      username: user.username,
                      onTap: () => goUserPage(context, user.uid),
                    );
                  },
                );
              },
            ),
    );
  }
}
