import 'package:flutter/widgets.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/navigation/go_router.dart';
import 'package:flutter_twitter_clone/presentation/components/my_post_tile.dart';

class MyPostTabList extends StatefulWidget {
  final List<Post> posts;
  const MyPostTabList({super.key, required this.posts});

  @override
  State<MyPostTabList> createState() => _MyPostTabListState();
}

class _MyPostTabListState extends State<MyPostTabList>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(
        context);
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        return MyPostTile(
          post: post,
          onUserTap: () => goUserPage(context, post.uid),
          onPostTap: () => goPostPage(context, post),
        );
      },
    );
  }
}
