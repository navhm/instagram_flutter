part of 'search_cubit.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  const SearchState({required this.users, required this.searchStatus, required this.failure});

  final List<User> users;
  final SearchStatus searchStatus;
  final Failure failure;

  factory SearchState.initial (){
    return const SearchState(users: [], searchStatus: SearchStatus.initial, failure: Failure());
  }

  @override
  List<Object> get props => [users, searchStatus, failure ];

  SearchState copyWith({
    List<User>? users,
    SearchStatus? searchStatus,
    Failure? failure,
  }) {
    return SearchState(
      users: users ?? this.users,
      searchStatus: searchStatus ?? this.searchStatus,
      failure: failure ?? this.failure,
    );
  }
}
