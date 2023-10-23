import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/blocs/blocs.dart';
import 'package:instagram_flutter/enums/enums.dart';
import 'package:instagram_flutter/screens/createPosts/cubit/create_posts_cubit.dart';
import 'package:instagram_flutter/screens/explore/cubit/search_cubit.dart';
import 'package:instagram_flutter/screens/feed/bloc/feed_bloc.dart';
import 'package:instagram_flutter/screens/feed/cubit/like_post_cubit.dart';
import 'package:instagram_flutter/screens/nav/cubit/nav_bar_cubit.dart';
import 'package:instagram_flutter/widgets/bottom_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/screens/screens.dart';

import '../../repositories/repositories.dart';

class NavScreen extends StatelessWidget {
  const NavScreen({super.key});

  static const String routeName = '/nav';

  static Route getRoute() {
    return PageRouteBuilder(
        pageBuilder: (_, __, ___) => BlocProvider<NavBarCubit>(
              create: (context) => NavBarCubit(),
              child: const NavScreen(),
            ),
        settings: const RouteSettings(name: routeName));
  }

  static List<Widget> screens = [
    BlocProvider(
      create: (context) => FeedBloc(
          postsRepository: context.read<PostsRepository>(),
          authBloc: context.read<AuthBloc>(),
          likePostCubit: context.read<LikePostCubit>()
          )
        ..add(FetchFeed()),
      child: const FeedScreen(),
    ),
    BlocProvider(
      create: (context) =>
          SearchCubit(userRepository: context.read<UserRepository>()),
      child: const ExploreScreen(),
    ),
    BlocProvider(
      create: (context) => CreatePostsCubit(
          postsRepository: context.read<PostsRepository>(),
          storageRepository: context.read<StorageRepository>(),
          authBloc: context.read<AuthBloc>()),
      child: CreatePostsScreen(),
    ),
    const NotifcationsScreen(),
    const ProfileScreen()
  ];

  final Map<BottomNavItem, (IconData, IconData)> items = const {
    BottomNavItem.feed: (Icons.home_outlined, Icons.home_filled),
    BottomNavItem.search: (CupertinoIcons.search, CupertinoIcons.search),
    BottomNavItem.create: (CupertinoIcons.plus_app, CupertinoIcons.plus_app),
    BottomNavItem.notifications: (Icons.favorite_border, Icons.favorite),
    BottomNavItem.profile: (Icons.account_circle_outlined, Icons.account_circle)
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBarCubit, NavBarState>(
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: BottomNavBar(
              items: items,
              selectedItem: state.selectedItem,
              onTap: (index) {
                final selectedItem = BottomNavItem.values[index];
                context.read<NavBarCubit>().updateNavBarItem(selectedItem);
              }),
          body: BlocProvider(
            create: (context) => ProfileBloc(
                userRepository: context.read<UserRepository>(),
                postsRepository: context.read<PostsRepository>(),
                likePostCubit: context.read<LikePostCubit>(),
                authBloc: context.read<AuthBloc>())
              ..add(
                ProfileLoadUser(
                    userId: context.read<AuthBloc>().state.user!.uid),
              ),
            child: screens[state.selectedItem.index],
          ),
        );
      },
    );
  }
}
