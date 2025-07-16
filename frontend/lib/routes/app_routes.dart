import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../auth/signup_screen.dart';

import '../screens/home_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignUpScreen(),
    home: (context) => const HomeScreen(),
  };
}
