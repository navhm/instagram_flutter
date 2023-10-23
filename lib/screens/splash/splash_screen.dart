import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:instagram_flutter/screens/screens.dart';
import '../../blocs/blocs.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  static Route getRoute() {
    return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: const RouteSettings(name: routeName));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prevState, state) => prevState.status != state.status,
      listener: (context, state) {
        if(state.status == AuthStatus.authenticated){
          FlutterNativeSplash.remove();
          //navigate to nav screen
          print('User is logged in');
          Navigator.of(context).pushAndRemoveUntil(NavScreen.getRoute(), (route) => false);
          // Navigator.of(context).pushNamed(NavScreen.routeName);
        }
        else if(state.status == AuthStatus.unauthenticated){
          FlutterNativeSplash.remove();
          //navigate to login screen.
          print('User is not logged in.');
          Navigator.of(context).pushNamed(LoginScreen.routeName);
        }
      },
      child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
    );
  }
}
