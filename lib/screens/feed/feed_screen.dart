import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/screens/feed/bloc/feed_bloc.dart';
import 'package:instagram_flutter/screens/feed/cubit/like_post_cubit.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/post_view.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ScrollController? _scrollController;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController!.offset >=
                _scrollController!.position.maxScrollExtent &&
            !_scrollController!.position.outOfRange &&
            context.read<FeedBloc>().state.feedStatus !=
                FeedStatus.paginating) {
          context.read<FeedBloc>().add(PaginateFeed());
        }
      });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.feedStatus == FeedStatus.error) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorDialog(content: state.failure.message!));
        }
      },
      builder: (context, state) {
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
          body: RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(FetchFeed());
              },
              child: _buildBody(state)),
        );
      },
    );
  }

  void showQrCode(BuildContext context, Image image) async {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return Container(
            padding: const EdgeInsets.all(12),
            height: 370,
            child: Column(
              children: <Widget>[
                const Center(
                    child: Text(
                  'Qr Code',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                )),
                const SizedBox(
                  height: 10,
                ),
                Image(
                  image: image.image,
                  height: 250,
                  width: 250,
                ),
                IntrinsicWidth(
                  stepWidth: 300,
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(this.context),
                      child: const Center(child: Text('Close'))),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildBody(FeedState state) {
    switch (state.feedStatus) {
      case FeedStatus.loading:
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).primaryColorLight,
          ),
        );
      default:
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.posts.length,
                  itemBuilder: ((context, index) {
                    final post = state.posts[index];
                    final likedPostState = context.watch<LikePostCubit>().state;
                    final isLiked =
                        likedPostState.likedPostIds.contains(post!.id);
                    final recentlyLiked =
                        likedPostState.newLikedPostIds.contains(post.id);
                    return PostView(
                      post: post,
                      isLiked: isLiked,
                      recentlyLiked: recentlyLiked,
                      onLike: () {
                        if (isLiked) {
                          context
                              .read<LikePostCubit>()
                              .unlikePost(postId: post.id!);
                        } else {
                          context.read<LikePostCubit>().likePost(post: post);
                        }
                      },
                      onShare: () async {
                        sharePost(post);
                      },
                    );
                  })),
            ),
            Visibility(
              visible: state.feedStatus == FeedStatus.paginating ? true : false,
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        );
    }
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
      showSuccessSnackBar(message: 'Link shared successfully.');
      BranchEvent event = BranchEvent.customEvent('Sharing post');
      FlutterBranchSdk.trackContentWithoutBuo(branchEvent: event);
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
