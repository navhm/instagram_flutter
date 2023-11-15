import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:instagram_flutter/blocs/auth/auth_bloc.dart';
import 'package:instagram_flutter/blocs/auth/simple_bloc_observer.dart';
import 'package:instagram_flutter/config/custom_router.dart';
import 'package:instagram_flutter/constants.dart';
import 'package:instagram_flutter/repositories/branch/branch_repositpry.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:instagram_flutter/screens/feed/cubit/like_post_cubit.dart';
import 'package:instagram_flutter/screens/screens.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  //preserve the splashScreen until the user state is known
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  EquatableConfig.stringify = kDebugMode;

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // Determine the status bar text and icon color based on the theme brightness
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  Bloc.observer = SimpleBlocObserver();

  //uncomment to validate FlutterBranchSDK integration
  FlutterBranchSdk.validateSDKIntegration();

  //initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository()),
        RepositoryProvider<UserRepository>(
            create: (context) => UserRepository()),
        RepositoryProvider<StorageRepository>(
            create: (context) => StorageRepository()),
        RepositoryProvider<PostsRepository>(
            create: (context) => PostsRepository()),
        RepositoryProvider<BranchRepository>(
            create: (context) => BranchRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<LikePostCubit>(
            create: (context) => LikePostCubit(
              postsRepository: context.read<PostsRepository>(),
              authBloc: context.read<AuthBloc>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Instagram Flutter',
          debugShowCheckedModeBanner: false,
          theme: lightThemeData,
          darkTheme: darkThemeData,
          onGenerateRoute: CustomRouter.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
