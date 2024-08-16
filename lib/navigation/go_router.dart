import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/presentation/pages/home_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/login_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/register_page.dart';
import 'package:flutter_twitter_clone/presentation/pages/settings_page.dart';
import 'package:flutter_twitter_clone/presentation/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRoute {
  static const String home = "Home";
  static const String settings = "Settings";
  static const String login = "Login";
  static const String register = "Register";
}

Provider<GoRouter> router(AuthenticationProvider authProvider) {
  List<String> routes = ["/login", "/register"];

  return Provider(
    create: (context) {
      return GoRouter(
        refreshListenable: authProvider,
        initialLocation: authProvider.isLoggedIn ? "/home" : "/login",
        redirect: (context, state) {
          log('state ${state.fullPath}');
          final isLoggedIn = authProvider.isLoggedIn;
          final isLoggingIn = routes.contains(state.matchedLocation);

          if (!isLoggedIn && !isLoggingIn) {
            // Jika belum login dan bukan di halaman login, arahkan ke halaman login
            return '/login';
          } else if (isLoggedIn && isLoggingIn) {
            // Jika sudah login dan berada di halaman login, arahkan ke homepage
            return '/home';
          }
          return null; // Tetap di halaman yang diminta
        },
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
              child: LoginPage(),
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
    },
  );
}

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
