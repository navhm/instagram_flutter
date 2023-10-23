part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

class FetchFeed extends FeedEvent {}

class PaginateFeed extends FeedEvent {}
