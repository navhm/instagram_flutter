import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/auth/auth_bloc.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/repositories/repositories.dart';

part 'create_posts_state.dart';

class CreatePostsCubit extends Cubit<CreatePostsState> {
  final PostsRepository _postsRepository;
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;

  CreatePostsCubit(
      {required PostsRepository postsRepository,
      required StorageRepository storageRepository,
      required AuthBloc authBloc})
      : _postsRepository = postsRepository,
        _storageRepository = storageRepository,
        _authBloc = authBloc,
        super(CreatePostsState.initial());

  void postImageChanged({required File file}) {
    emit(state.copyWith(imageFile: file));
  }

  void postCaptionChanged({required String caption}) {
    emit(state.copyWith(caption: caption));
  }

  void createPost() async {
    emit(state.copyWith(status: CreatePostStatus.submitting));
    try {
      //upload the image and get the download url
      final imageUrl =
          await _storageRepository.uploadPost(image: state.imageFile!);

      //get user info
      final author = User.empty.copyWith(id: _authBloc.state.user!.uid);

      //use that url here
      Post post = Post(
          author: author,
          imageUrl: imageUrl,
          caption: state.caption,
          likes: 0,
          dateTime: DateTime.now());
      await _postsRepository.createPost(post: post);
      emit(state.copyWith(status: CreatePostStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: CreatePostStatus.error,
          failure: const Failure(message: 'Create post failed')));
    }
  }

  void reset() {
    emit(CreatePostsState.initial());
  }
}
