import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/auth/auth_bloc.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/repositories/posts/post_repository.dart';

part 'comments_event.dart';
part 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;
  StreamSubscription<List<Future<Comment?>>>? _commentsSubscription;

  CommentsBloc(
      {required PostsRepository postsRepository, required AuthBloc authBloc})
      : _postsRepository = postsRepository,
        _authBloc = authBloc,
        super(CommentsState.initial()) {
    on<CommentsEvent>((event, emit) async {
      if (event is FetchComments) {
        emit(state.copyWith(post: event.post, status: CommentsStatus.loading));
        try {
          _commentsSubscription?.cancel();
          _commentsSubscription = _postsRepository
              .getPostComments(postId: event.post.id!)
              .listen((comments) async {
            final allComments = await Future.wait(comments);
            add(UpdateComments(comments: allComments));
          });
        } catch (e) {
          emit(
            state.copyWith(
              status: CommentsStatus.error,
              failure: const Failure(message: 'Unable to load post comments.'),
            ),
          );
        }
      } else if (event is UpdateComments) {
        emit(
          state.copyWith(
              comments: event.comments, status: CommentsStatus.loaded),
        );
      } else if (event is PostComment) {
        emit(state.copyWith(status: CommentsStatus.submitting));
        try {
          final author = User.empty.copyWith(id: _authBloc.state.user!.uid);
          final comment = Comment(
            author: author,
            content: event.content,
            postId: state.post!.id!,
            dateTime: DateTime.now(),
          );
          await _postsRepository.createComment(comment: comment);

          emit(state.copyWith(status: CommentsStatus.success));
        } catch (e) {
          emit(state.copyWith(
              status: CommentsStatus.error,
              failure: const Failure(message: 'Unable to post comment.')));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}
