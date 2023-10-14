// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, updated, error }

class ProfileState extends Equatable {
  final User? user;
  final ProfileStatus status;
  final bool isCurrentUser;
  final bool isFollowing;
  final Failure failure;
  final int tabPos;
  final List<Post?> posts;

  const ProfileState({
    this.user,
    required this.status,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.failure,
    required this.tabPos,
    required this.posts
  });

  factory ProfileState.initial() => const ProfileState(
      user: User.empty,
      status: ProfileStatus.initial,
      isCurrentUser: false,
      isFollowing: false,
      failure: Failure(),
      tabPos: 0,
      posts: []);

  @override
  List<Object?> get props =>
      [user, status, isCurrentUser, isFollowing, failure, tabPos, posts];

  ProfileState copyWith({
    User? user,
    ProfileStatus? status,
    bool? isCurrentUser,
    bool? isFollowing,
    Failure? failure,
    int? tabPos,
    List<Post?>? posts,
  }) {
    return ProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isFollowing: isFollowing ?? this.isFollowing,
      failure: failure ?? this.failure,
      tabPos: tabPos ?? this.tabPos,
      posts: posts ?? this.posts
    );
  }
}
