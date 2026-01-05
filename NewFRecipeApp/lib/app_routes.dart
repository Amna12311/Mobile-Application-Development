import 'package:flutter/material.dart';

// Splash + Auth
import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';

// Main screens
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notification/notifications_screen.dart';
import 'screens/saved/saved_recipe_screen.dart';

// Recipe
import 'screens/recipe/add_recipe_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/filter/filter_screen.dart';

class AppRoutes {
  // ✅ Routes names
  static const splash = '/splash';
  static const authGate = '/authGate';

  static const signIn = '/signIn';
  static const signUp = '/signUp';

  static const home = '/home';
  static const profile = '/profile';
  static const notifications = '/notifications';
  static const saved = '/saved';

  static const addRecipe = '/addRecipe';
  static const search = '/search';
  static const filter = '/filter';

  // ✅ Routes map
  static Map<String, WidgetBuilder> get routes => {
    // ✅ Splash first
    splash: (_) => const SplashScreen(),

    // ✅ AuthGate decides Home or SignIn
    authGate: (_) => const AuthGate(),

    // Auth
    signIn: (_) => const SignInScreen(),
    signUp: (_) => const SignUpScreen(),

    // Main
    home: (_) => const HomeScreen(),
    profile: (_) => const ProfileScreen(),
    notifications: (_) => const NotificationsScreen(),
    saved: (_) => const SavedRecipeScreen(),

    // Recipe + search
    addRecipe: (_) => const AddRecipeScreen(),
    search: (_) => const SearchScreen(),
    filter: (_) => const FilterScreen(),
  };
}
