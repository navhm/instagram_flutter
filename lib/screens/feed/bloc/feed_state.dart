// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, loaded, paginating, error }

class FeedState extends Equatable {
  const FeedState(
      {required this.posts, required this.feedStatus, required this.failure});

  final List<Post?> posts;
  final FeedStatus feedStatus;
  final Failure failure;

  factory FeedState.initial() {
    return const FeedState(
        posts: [], feedStatus: FeedStatus.initial, failure: Failure());
  }

  @override
  List<Object?> get props => [posts, feedStatus, failure];

  FeedState copyWith({
    List<Post?>? posts,
    FeedStatus? feedStatus,
    Failure? failure,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      feedStatus: feedStatus ?? this.feedStatus,
      failure: failure ?? this.failure,
    );
  }
}
