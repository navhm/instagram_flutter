import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/blocs/auth/auth_bloc.dart';
import 'package:instagram_flutter/blocs/profile/profile_bloc.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/post_view.dart';
import 'package:instagram_flutter/widgets/prfile_info.dart';
import 'package:instagram_flutter/widgets/profile_stats.dart';
import 'package:instagram_flutter/widgets/user_profile_image.dart';

class ProfileScreenArgs {
  final String userId;

  const ProfileScreenArgs({
    required this.userId,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile_screen';

  static Route getRoute({required ProfileScreenArgs args}) {
    return MaterialPageRoute(
        builder: (context) => BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(
                  userRepository: context.read<UserRepository>(),
                  postsRepository: context.read<PostsRepository>(),
                  authBloc: context.read<AuthBloc>())
                ..add(
                  ProfileLoadUser(userId: args.userId),
                ),
              child: const ProfileScreen(),
            ),
        settings: const RouteSettings(name: routeName));
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        print('Checking profile status: $state');
        if (state.status == ProfileStatus.error) {
          //display error
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    content: state.failure.message!,
                  ));
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              titleSpacing: 20,
              title: Text(
                state.user!.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: state.isCurrentUser
                  ? [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.menu)),
                    ]
                  : null,
              automaticallyImplyLeading: false,
            ),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UserProfileImage(
                                radius: 40,
                                profileImageUrl: state.user!.profileImageUrl),
                            Expanded(
                                child: ProfileStats(
                              posts: state.posts.length,
                              followers: state.user!.followers.toString(),
                              following: state.user!.following.toString(),
                              isCurrentUser: state.isCurrentUser,
                              isFollowing: state.isFollowing,
                            )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: ProfileInfo(
                          username: state.user!.username,
                          bio: state.user!.bio,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: TabBar(
                    onTap: (i) =>
                        context.read<ProfileBloc>().add(ToggleTabs(pos: i)),
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.movie)),
                      Tab(icon: Icon(Icons.assignment_ind)),
                    ],
                  ),
                ),
                state.tabPos == 0
                    ? SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final post = state.posts[index];
                          return GestureDetector(
                            onTap: () {},
                            child: CachedNetworkImage(
                              imageUrl: post!.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          );
                        }, childCount: state.posts.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2.0,
                          crossAxisSpacing: 2.0,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final post = state.posts[index];
                          return PostView(
                            post: post!,
                            isLiked: false,
                          );
                        }, childCount: state.posts.length),
                      ),
                // SliverAppBar(
                //   titleSpacing: 20,
                //   title: Text(
                //     state.user!.username,
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                //   actions: state.isCurrentUser
                //       ? [
                //           IconButton(
                //               onPressed: () {}, icon: const Icon(Icons.menu)),
                //         ]
                //       : null,
                //   automaticallyImplyLeading: false,
                //   pinned: true,
                //   expandedHeight: 270.0,
                //   flexibleSpace: FlexibleSpaceBar(
                //     background: Padding(
                //       padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Row(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               UserProfileImage(
                //                   radius: 40,
                //                   profileImageUrl:
                //                       state.user!.profileImageUrl),
                //               const Column(
                //                 children: [
                //                   Text('0'),
                //                   Text('Posts'),
                //                 ],
                //               ),
                //               Column(
                //                 children: [
                //                   Text('${state.user!.followers}'),
                //                   const Text('Followers'),
                //                 ],
                //               ),
                //               Column(
                //                 children: [
                //                   Text('${state.user!.following}'),
                //                   const Text('Following'),
                //                 ],
                //               ),
                //             ],
                //           ),
                //           const SizedBox(
                //             height: 10,
                //           ),
                //           Text(
                //             state.user!.username,
                //             style: const TextStyle(
                //                 fontWeight: FontWeight.bold, fontSize: 15),
                //           ),
                //           const SizedBox(
                //             height: 5,
                //           ),
                //           const Text('This is my bio')
                //         ],
                //       ),
                //     ),
                //   ),
                //   bottom: const TabBar(
                // indicatorColor: Colors.white,
                // tabs: [
                //   Tab(icon: Icon(Icons.grid_on)),
                //   Tab(icon: Icon(Icons.movie)),
                //   Tab(icon: Icon(Icons.assignment_ind)),
                //     ],
                //   ),
                // ),
              ],
            ));
      },
    );
  }
}
