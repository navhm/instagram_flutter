// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:instagram_flutter/models/post_model.dart';

import 'package:instagram_flutter/repositories/posts/post_repository.dart';
import 'package:instagram_flutter/screens/deeplink/cubit/branch_cubit.dart';
import 'package:instagram_flutter/widgets/post_view.dart';

class PostScreenArgs {
  final String postId;

  const PostScreenArgs({
    required this.postId,
  });
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  static const String routeName = '/post_screen';

  static Route getRoute({required PostScreenArgs args}) {
    return MaterialPageRoute(
        builder: (context) => BlocProvider<BranchCubit>(
              create: (_) =>
                  BranchCubit(postsRepository: context.read<PostsRepository>())
                    ..fetchPost(postId: args.postId),
              child: const PostScreen(),
            ),
        settings: const RouteSettings(name: routeName));
  }

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 40.0,
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
      body: BlocConsumer<BranchCubit, BranchState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status == DeeplinkStatus.initial ||
              state.status == DeeplinkStatus.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColorLight,
                strokeWidth: 2,
              ),
            );
          } else if (state.status == DeeplinkStatus.loaded) {
            final post = state.post;
            return SingleChildScrollView(
              child: PostView(
                post: post!,
                isLiked: false,
                recentlyLiked: false,
                onLike: () {},
                onShare: () async {
                  sharePost(post);
                },
              ),
            );
          }
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  void sharePost(Post post) async {
    print(
        'Canonical data => identifier: post/${post.id} , url: ${post.imageUrl} , title: ${post.author.username} , descr: ${post.caption} , postId: ${post.id}');

    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'post/${post.id}',
      canonicalUrl: post.imageUrl,
      title: post.author.username,
      contentDescription: post.caption,
      imageUrl: post.imageUrl,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('postId', post.id)
        ..addCustomMetadata('contentType', 'post'),
      publiclyIndex: true,
      locallyIndex: true,
      expirationDateInMilliSec:
          DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
    );

    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'WhatsApp',
        feature: 'Share post',
        tags: ['Post'],
        campaign: 'Post Promo');

    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: buo,
        linkProperties: lp,
        messageText:
            'Checkout this post from ${post.author.username} on Instagram.',
        androidMessageTitle: 'Share via',
        androidSharingTitle: 'Share Post');

    if (response.success) {
      print('Link shared successfully. Posting event');
      BranchEvent event = BranchEvent.customEvent('Sharing post');
      FlutterBranchSdk.trackContentWithoutBuo(branchEvent: event);
      showSuccessSnackBar(message: 'Link shared successfully');
    } else {
      print(
          'Failed to generate link: ${response.errorCode} - ${response.errorMessage}');
      showErrorSnackBar(
          message:
              'Failed to generate link: ${response.errorCode} - ${response.errorMessage}');
    }
  }

  void showSuccessSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(30.0),
        backgroundColor: Colors.green,
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  void showErrorSnackBar({required String message, int duration = 2}) {
    scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(30.0),
        backgroundColor: Colors.red,
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }
}
