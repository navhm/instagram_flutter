import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/auth/auth_bloc.dart';
import 'package:instagram_flutter/models/failure_model.dart';
import 'package:instagram_flutter/models/post_model.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:instagram_flutter/screens/feed/cubit/like_post_cubit.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;
  final LikePostCubit _likePostCubit;

  FeedBloc(
      {required PostsRepository postsRepository,
      required AuthBloc authBloc,
      required LikePostCubit likePostCubit})
      : _postsRepository = postsRepository,
        _authBloc = authBloc,
        _likePostCubit = likePostCubit,
        super(FeedState.initial()) {
    on<FeedEvent>((event, emit) async {
      if (event is FetchFeed) {
        emit(state.copyWith(feedStatus: FeedStatus.loading));
        try {
          final posts = await _postsRepository.getUserFeed(
              userId: _authBloc.state.user!.uid);

          _likePostCubit.clearAllLikedPosts();

          final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
          _likePostCubit.updateLikedPosts(postIds: likedPostIds);

          emit(state.copyWith(posts: posts, feedStatus: FeedStatus.loaded));
        } catch (e) {
          emit(state.copyWith(
              feedStatus: FeedStatus.error,
              failure: const Failure(message: 'Unable to load posts')));
        }
      } else if (event is PaginateFeed) {
        try {
          emit(state.copyWith(feedStatus: FeedStatus.paginating));
          final lastPostId =
              state.posts.isNotEmpty ? state.posts.last!.id : null;
          final posts = await _postsRepository.getUserFeed(
              userId: _authBloc.state.user!.uid, lastPostId: lastPostId);
          final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);

          final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
          _likePostCubit.updateLikedPosts(postIds: likedPostIds);

          emit(state.copyWith(
              posts: updatedPosts, feedStatus: FeedStatus.loaded));
        } catch (e) {
          emit(state.copyWith(
              feedStatus: FeedStatus.error,
              failure: const Failure(message: 'Unable to load posts')));
        }
      }
    });
  }
}
