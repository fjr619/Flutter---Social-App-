import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/domain/model/post.dart';
import 'package:flutter_twitter_clone/main.dart';
import 'package:flutter_twitter_clone/presentation/pages/account_settings_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/blocked_user_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/follow_list_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/home_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/login_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/post_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/profile_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/register_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/settings_page.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:flutter_twitter_clone/presentation/provider/database_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRoute {
  static const String home = "Home";
  static const String settings = "Settings";
  static const String login = "Login";
  static const String register = "Register";
  static const String profile = "Profile";
  static const String post = "Post";
  static const String blockedUser = "BlockedUser";
  static const String accountSettings = "AccountSettings";
  static const String following = "Following";
}

Provider<GoRouter> router() {
  List<String> routes = ["/login", "/register"];

  return Provider(
    create: (context) {
      AuthenticationProvider authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      DatabaseProvider firestoreProvider =
          Provider.of<DatabaseProvider>(context, listen: false);

      return GoRouter(
        navigatorKey: navigatorKey,
        refreshListenable: Listenable.merge([
          firestoreProvider,
          authProvider,
        ]),
        initialLocation: authProvider.isLoggedIn ? "/home" : "/login",
        redirect: (context, state) {
          final isLoggedIn = authProvider.isLoggedIn;
          final isLoggingIn = state.uri.toString() == '/login';
          final isRegister = state.uri.toString() == '/register';
          final isStateUriNotAuthRoute = routes.contains(state.matchedLocation);
          final isSaveUserProfile = firestoreProvider.isSaveUserProfile;

          if (!isLoggedIn && !isStateUriNotAuthRoute) {
            // Jika belum login dan bukan di halaman login atau register, arahkan ke halaman login
            return '/login';
          } else if (isLoggedIn && isLoggingIn) {
            // Jika sudah login dan berada di halaman login, arahkan ke homepage
            return '/home';
          } else if (isLoggedIn && isRegister && isSaveUserProfile) {
            // Jika sudah register dan berada di halaman register, arahkan ke homepage
            return '/home';
          }

          return null; // Tetap di halaman yang diminta
        },
        routes: [
          //home
          GoRoute(
            name: AppRoute.home,
            path: '/home',
            pageBuilder: (context, state) => buildTransitionpage(
              key: state.pageKey,
              child: const HomePage(),
            ),
          ),

          //settings
          GoRoute(
            name: AppRoute.settings,
            path: '/settings',
            pageBuilder: (context, state) => buildTransitionpage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),

          //login
          GoRoute(
            name: AppRoute.login,
            path: '/login',
            pageBuilder: (context, state) => buildTransitionpage(
              key: state.pageKey,
              child: const LoginPage(),
            ),
          ),

          //register
          GoRoute(
            name: AppRoute.register,
            path: '/register',
            pageBuilder: (context, state) => buildTransitionpage(
              key: state.pageKey,
              child: const RegisterPage(),
            ),
          ),

          //profile
          GoRoute(
            name: AppRoute.profile,
            path: '/profile/:uid',
            pageBuilder: (context, state) {
              final uid = state.pathParameters["uid"]!;
              return buildTransitionpage(
                key: state.pageKey,
                child: ProfilePage(
                  uid: uid,
                ),
              );
            },
          ),

          //post
          GoRoute(
            name: AppRoute.post,
            path: '/post',
            pageBuilder: (context, state) {
              final post = state.extra! as Post;
              return buildTransitionpage(
                key: state.pageKey,
                child: PostPage(post: post),
              );
            },
          ),

          //blocked user
          GoRoute(
            name: AppRoute.blockedUser,
            path: '/blockedUser',
            pageBuilder: (context, state) {
              return buildTransitionpage(
                key: state.pageKey,
                child: const BlockedUserPage(),
              );
            },
          ),

          //account settings
          GoRoute(
            name: AppRoute.accountSettings,
            path: '/accountSettings',
            pageBuilder: (context, state) {
              return buildTransitionpage(
                key: state.pageKey,
                child: const AccountSettingsPage(),
              );
            },
          ),

          //following
          GoRoute(
            path: '/following/:uid/:userName',
            name: AppRoute.following,
            pageBuilder: (context, state) {
              final uid = state.pathParameters["uid"]!;
              final userName = state.pathParameters["userName"]!;
              return buildTransitionpage(
                key: state.pageKey,
                child: FollowListPage(
                  uid: uid,
                  userName: userName,
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

CustomTransitionPage buildTransitionpage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 500), // Durasi default 300ms
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
        child: child,
      );
    },
  );
}

void goUserPage(BuildContext context, String uid) {
  context.pushNamed(AppRoute.profile, pathParameters: {'uid': uid});
}

void goPostPage(BuildContext context, Post post) {
  context.pushNamed(AppRoute.post, extra: post);
}

void goBlockedUserPage(BuildContext context) {
  context.pushNamed(AppRoute.blockedUser);
}

void goAccountSettingsPage(BuildContext context) {
  context.pushNamed(AppRoute.accountSettings);
}

void goToFollowingPage(BuildContext context, String uid, String userName) {
  context.pushNamed(AppRoute.following,
      pathParameters: {'uid': uid, 'userName': userName});
}
