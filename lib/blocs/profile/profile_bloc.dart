import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/blocs.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;

  StreamSubscription<List<Future<Post?>>>? _postsSubscription;

  ProfileBloc(
      {required UserRepository userRepository, required PostsRepository postsRepository, required AuthBloc authBloc})
      : _userRepository = userRepository,
        _postsRepository = postsRepository,
        _authBloc = authBloc,
        super(ProfileState.initial()) {
    // add(ProfileLoadUser(
    //             userId: authBloc.state.user!.uid))
    //why not add ProfileLoadUser event here instead of nav_screen?
    //cant add this because the event handler on<ProfileEvent> is not yet registered.
    on<ProfileEvent>((event, emit) async {
      if (event is ProfileLoadUser) {
        emit(state.copyWith(status: ProfileStatus.loading));
        try {
          final user = await _userRepository.getUserById(userId: event.userId);
          final currentUser = _authBloc.state.user?.uid == event.userId;

          _postsSubscription?.cancel();
          _postsSubscription = _postsRepository.getUserPosts(userId: event.userId).listen((posts) async { 
            final allPosts = await Future.wait(posts);
            add(ProfileUpdatePosts(posts: allPosts));
          });

          emit(state.copyWith(
              user: user,
              status: ProfileStatus.loaded,
              isCurrentUser: currentUser));
        } catch (error) {
          emit(state.copyWith(
              status: ProfileStatus.error,
              failure: const Failure(message: 'Unable to load profile')));
        }
      }
      else if(event is ToggleTabs) {
        emit(state.copyWith(tabPos: event.pos));
      }
      else if(event is ProfileUpdatePosts){
      emit(state.copyWith(posts: event.posts));
      }
    });
  }

  @override
  Future<void> close() {
    _postsSubscription?.cancel();
    return super.close();
  }
}
