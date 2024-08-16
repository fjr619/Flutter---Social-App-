import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/pages/home_page.dart';
import 'package:flutter_twitter_clone/pages/login_page.dart';
import 'package:flutter_twitter_clone/pages/register_page.dart';
import 'package:flutter_twitter_clone/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  static const String home = "Home";
  static const String settings = "Settings";
  static const String login = "Login";
  static const String register = "Register";
}

final router = GoRouter(
  initialLocation: "/login",
  routes: [
    GoRoute(
      name: AppRoute.home,
      path: '/home',
      pageBuilder: (context, state) => _buildTransitionpage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
    GoRoute(
      name: AppRoute.settings,
      path: '/settings',
      pageBuilder: (context, state) => _buildTransitionpage(
        key: state.pageKey,
        child: const SettingsPage(),
      ),
    ),
    GoRoute(
      name: AppRoute.login,
      path: '/login',
      pageBuilder: (context, state) => _buildTransitionpage(
        key: state.pageKey,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      name: AppRoute.register,
      path: '/register',
      pageBuilder: (context, state) => _buildTransitionpage(
        key: state.pageKey,
        child: const RegisterPage(),
      ),
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
