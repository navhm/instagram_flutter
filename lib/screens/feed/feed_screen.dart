import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Widget _buildBody(FeedState state) {
    switch (state.feedStatus) {
      case FeedStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
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
                    final isLiked = likedPostState.likedPostIds.contains(post!.id);
                    final recentlyLiked = likedPostState.newLikedPostIds.contains(post.id);
                    return PostView(
                      post: post,
                      isLiked: isLiked,
                      recentlyLiked: recentlyLiked,
                      onLike: () {
                        if(isLiked){
                          context.read<LikePostCubit>().unlikePost(postId: post.id!);
                        }
                        else {
                          context.read<LikePostCubit>().likePost(post: post);
                        }
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
}
