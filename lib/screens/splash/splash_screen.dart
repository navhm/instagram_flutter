// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:instagram_flutter/models/product_model.dart';
import 'package:instagram_flutter/screens/deeplink/post_screen.dart';
import 'package:instagram_flutter/screens/deeplink/product_screen.dart';
import 'package:instagram_flutter/screens/screens.dart';
import '../../blocs/blocs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  static Route getRoute() {
    return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: const RouteSettings(name: routeName));
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<Map>? streamSubscription;

  @override
  void initState() {
    super.initState();

    listenDynamicLinks();
  }

  void listenDynamicLinks() async {
    streamSubscription = FlutterBranchSdk.initSession().listen((data) {
      print('listenDynamicLinks - DeepLink Data: $data');
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        print(
            '------------------------------------Link clicked----------------------------------------------');

        print('Link data: $data');

        if (data.containsKey('postId')) {
          print('this link is a post link');

          Navigator.of(context).pushAndRemoveUntil(
              PostScreen.getRoute(
                args: PostScreenArgs(
                  postId: data['postId'],
                ),
              ),
              (route) => false);

          //navigate to post screen and fetch and display the post.
        } else if (data.containsKey('productId')) {
          Product product = Product(
            productId: data['productId'],
            title: data['\$og_title'],
            imageUrl: data['\$og_image_url'],
            price: data['\$amount'],
            currency: data['\$currency'],
            productName: data['productName'],
            brandName: data['brandName'],
            description: data['\$og_description'],
          );

          Navigator.of(context).pushAndRemoveUntil(
              ProductScreen.getRoute(
                args: ProductScreenArgs(product: product),
              ),
              (route) => false);
          //navigate to product screen and fetch and display the product.
        }
      }
    }, onError: (error) {
      print('InitSesseion error: ${error.toString()}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prevState, state) => prevState.status != state.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          FlutterNativeSplash.remove();
          //navigate to nav screen
          print('User is logged in');
          Navigator.of(context)
              .pushAndRemoveUntil(NavScreen.getRoute(), (route) => false);
          // Navigator.of(context).pushNamed(NavScreen.routeName);
        } else if (state.status == AuthStatus.unauthenticated) {
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
