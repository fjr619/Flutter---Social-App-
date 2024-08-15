import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/pages/home_page.dart';
import 'package:flutter_twitter_clone/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(
      name: 'Home',
      path: '/home',
      pageBuilder: (context, state) => _buildTransitionpage(
        key: state.pageKey,
        child: const HomePage(),
      ),
      // builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'Settings',
      path: '/settings',
      pageBuilder: (context, state) => _buildTransitionpage(
        key: state.pageKey,
        child: const SettingsPage(),
      ),
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

CustomTransitionPage _buildTransitionpage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 200), // Durasi default 300ms
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
