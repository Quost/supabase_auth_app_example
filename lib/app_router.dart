import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';

class AppRouter {
  static const String root = '/';
  static const String home = '/home';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      default:
        return MaterialPageRoute(builder: (_) => const SignInPage());
    }
  }
}
