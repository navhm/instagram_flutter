// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'like_post_cubit.dart';

class LikePostState extends Equatable {
  const LikePostState({required this.likedPostIds, required this.newLikedPostIds});

  final Set<String> likedPostIds;
  final Set<String> newLikedPostIds;

  factory LikePostState.initial (){
    return const LikePostState(likedPostIds: <String>{}, newLikedPostIds: <String>{});
  }

  @override
  List<Object?> get props => [likedPostIds, newLikedPostIds];

  LikePostState copyWith({
    Set<String>? likedPostIds,
    Set<String>? newLikedPostIds,
  }) {
    return LikePostState(
      likedPostIds: likedPostIds ?? this.likedPostIds,
      newLikedPostIds: newLikedPostIds ?? this.newLikedPostIds,
    );
  }
}
