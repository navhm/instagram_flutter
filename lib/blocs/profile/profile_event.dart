// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadUser extends ProfileEvent {
  final String userId;

  const ProfileLoadUser({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class ToggleTabs extends ProfileEvent {
  final int pos;
  const ToggleTabs({
    required this.pos,
  });

  @override
  List<Object?> get props => [pos];
}

class ProfileUpdatePosts extends ProfileEvent {
  final List<Post?> posts;
  const ProfileUpdatePosts({
    required this.posts,
  });

  @override
  List<Object?> get props => [posts];
}

class ProfileFollowUser extends ProfileEvent {}

class ProfileUnFollowUser extends ProfileEvent {}
