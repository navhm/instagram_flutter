import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/models/failure_model.dart';
import 'package:instagram_flutter/models/post_model.dart';
import 'package:instagram_flutter/models/product_model.dart';
import 'package:instagram_flutter/repositories/posts/post_repository.dart';

part 'branch_state.dart';

class BranchCubit extends Cubit<BranchState> {
  final PostsRepository _postsRepository;
  BranchCubit({required PostsRepository postsRepository})
      : _postsRepository = postsRepository,
        super(BranchState.initial());

  void fetchPost({required String postId}) async {
    emit(state.copyWith(status: DeeplinkStatus.loading));
    try {
      final post = await _postsRepository.getPostById(postId: postId);
      emit(state.copyWith(post: post, status: DeeplinkStatus.loaded,),);
    } catch (e) {
      emit(
        state.copyWith(
          status: DeeplinkStatus.error,
          failure: const Failure(message: 'Unable to get post'),
        ),
      );
    }
  }
}
