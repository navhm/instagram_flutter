import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/blocs.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/repositories/posts/post_repository.dart';

part 'like_post_state.dart';

class LikePostCubit extends Cubit<LikePostState> {
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;

  LikePostCubit(
      {required PostsRepository postsRepository, required AuthBloc authBloc})
      : _postsRepository = postsRepository,
        _authBloc = authBloc,
        super(LikePostState.initial());

  void updateLikedPosts({required Set<String> postIds}) {
    emit(
      state.copyWith(
        likedPostIds: Set<String>.from(state.likedPostIds)..addAll(postIds),
      ),
    );
  }

  void likePost({required Post post}) {
    _postsRepository.likePost(post: post, userId: _authBloc.state.user!.uid);
    emit(
      state.copyWith(
        likedPostIds: Set<String>.from(state.likedPostIds)..add(post.id!),
        newLikedPostIds: Set<String>.from(state.newLikedPostIds)..add(post.id!),
      ),
    );
  }

  void unlikePost({required String postId}) {
    _postsRepository.unlikePost(postId: postId, userId: _authBloc.state.user!.uid);
    emit(
      state.copyWith(
        likedPostIds: Set<String>.from(state.likedPostIds)..remove(postId),
        newLikedPostIds: Set<String>.from(state.newLikedPostIds)..remove(postId),
      ),
    );
  }

  void clearAllLikedPosts(){
    emit(LikePostState.initial());
  }
}
