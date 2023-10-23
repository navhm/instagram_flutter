import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/models/failure_model.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:instagram_flutter/models/user_model.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final UserRepository _userRepository;
  SearchCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SearchState.initial());

  void searchUsers(String searchQuery) async {
    emit(state.copyWith(searchStatus: SearchStatus.loading));
    try {
      final users = await _userRepository.searchUsers(query: searchQuery);
      emit(state.copyWith(users: users, searchStatus: SearchStatus.loaded));
    } catch (error) {
      emit(state.copyWith(
          searchStatus: SearchStatus.error,
          failure: const Failure(
              message: 'Somethinng went wrong. Please tryv again.')));
    }
  }

  void clearSearch() {
    emit(state.copyWith(users: [], searchStatus: SearchStatus.initial));
  }
}
