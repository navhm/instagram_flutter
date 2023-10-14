import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile/edit_profile_screen.dart';
import 'package:instagram_flutter/screens/screens.dart';
import 'package:instagram_flutter/screens/signup/sign_up_screen.dart';

class CustomRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
            settings: const RouteSettings(name: '/'),
            builder: (_) => const Scaffold());
      case SplashScreen.routeName:
        return SplashScreen.getRoute();
      case LoginScreen.routeName:
        return LoginScreen.getRoute();
      case SignUpScreen.routeName:
        return SignUpScreen.getRoute();
      case NavScreen.routeName:
        return NavScreen.getRoute();
      case EditProfileScreen.routeName:
        return EditProfileScreen.getRoute(args: settings.arguments as EditProfileScreenArgs); 
      //check this Profile screen router.
      case ProfileScreen.routeName:
        return ProfileScreen.getRoute(args: settings.arguments as ProfileScreenArgs);
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: '/error'),
        builder: (_) => Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(child: Text("Something went wrong.")),
            ));
  }
}
