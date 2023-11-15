import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/blocs.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/screens/feed/cubit/like_post_cubit.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;
  final LikePostCubit _likePostCubit;

  StreamSubscription<List<Future<Post?>>>? _postsSubscription;

  ProfileBloc(
      {required UserRepository userRepository,
      required PostsRepository postsRepository,
      required AuthBloc authBloc,
      required LikePostCubit likePostCubit})
      : _userRepository = userRepository,
        _postsRepository = postsRepository,
        _authBloc = authBloc,
        _likePostCubit = likePostCubit,
        super(ProfileState.initial()) {
    //add(ProfileLoadUser(userId: authBloc.state.user!.uid))
    //cant add this because the event handler on<ProfileEvent> is not yet registered.

    on<ProfileEvent>((event, emit) async {
      if (event is ProfileLoadUser) {
        emit(state.copyWith(status: ProfileStatus.loading));
        try {
          final user = await _userRepository.getUserById(userId: event.userId);
          final isCurrentUser = _authBloc.state.user?.uid == event.userId;

          final isFollowing = await _userRepository.isFollowing(
              userId: _authBloc.state.user!.uid, otherUserId: event.userId);

          _postsSubscription?.cancel();
          _postsSubscription = _postsRepository
              .getUserPosts(userId: event.userId)
              .listen((posts) async {
            final allPosts = await Future.wait(posts);

            add(ProfileUpdatePosts(posts: allPosts));
          });

          emit(state.copyWith(
              user: user,
              status: ProfileStatus.loaded,
              isFollowing: isFollowing,
              isCurrentUser: isCurrentUser));
        } catch (error) {
          emit(state.copyWith(
              status: ProfileStatus.error,
              failure: const Failure(message: 'Unable to load profile')));
        }
      } else if (event is ToggleTabs) {
        emit(state.copyWith(tabPos: event.pos));
      } else if (event is ProfileUpdatePosts) {
        final likedPostIds = await _postsRepository.getLikedPostIds(
            userId: _authBloc.state.user!.uid, posts: event.posts);
        _likePostCubit.updateLikedPosts(postIds: likedPostIds);

        emit(state.copyWith(posts: event.posts));
      } else if (event is ProfileFollowUser) {
        followUser(event, emit);
      } else if (event is ProfileUnFollowUser) {
        unFollowUser(event, emit);
      }
    });
  }

  void logoutUser() {
    _authBloc.add(AuthLogoutRequested());
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }

//TODO: fix emit issue due to add(ProfileUpdatePosts)
  Future<void> loadUserProfile(
      ProfileLoadUser event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _userRepository.getUserById(userId: event.userId);
      final isCurrentUser = _authBloc.state.user?.uid == event.userId;

      final isFollowing = await _userRepository.isFollowing(
          userId: _authBloc.state.user!.uid, otherUserId: event.userId);

      _postsSubscription?.cancel();
      _postsSubscription = _postsRepository
          .getUserPosts(userId: event.userId)
          .listen((posts) async {
        final allPosts = await Future.wait(posts);
        add(ProfileUpdatePosts(posts: allPosts));
      });

      emit(state.copyWith(
          user: user,
          status: ProfileStatus.loaded,
          isFollowing: isFollowing,
          isCurrentUser: isCurrentUser));
    } catch (error) {
      emit(state.copyWith(
          status: ProfileStatus.error,
          failure: const Failure(message: 'Unable to load profile')));
    }
  }

//TODO: check stream implementation with yield.
  void followUser(ProfileFollowUser event, Emitter<ProfileState> emit) async {
    try {
      _userRepository.followUser(
          userId: _authBloc.state.user!.uid, followUserId: state.user!.id);
      final updatedUser =
          state.user!.copyWith(followers: state.user!.followers + 1);
      emit(state.copyWith(user: updatedUser, isFollowing: true));
    } catch (e) {
      emit(state.copyWith(
          status: ProfileStatus.error,
          failure: const Failure(message: 'Follow user failed')));
    }
  }

  void unFollowUser(ProfileUnFollowUser event, Emitter<ProfileState> emit) {
    try {
      _userRepository.unFollowUser(
          userId: _authBloc.state.user!.uid, unFollowUserId: state.user!.id);

      final updatedUser =
          state.user!.copyWith(followers: state.user!.followers - 1);
      emit(state.copyWith(user: updatedUser, isFollowing: false));
    } catch (e) {
      emit(state.copyWith(
          status: ProfileStatus.error,
          failure: const Failure(message: 'Unfollow user failed')));
    }
  }
}
