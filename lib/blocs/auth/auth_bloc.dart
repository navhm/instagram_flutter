import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:instagram_flutter/repositories/auth/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<auth.User?>? _userSubscription;
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.unknown()) {
    _userSubscription = _authRepository.user.listen((value) {
      add(AuthUserChanged(user: value));
    });
    on<AuthEvent>((event, emit) async {
      if (event is AuthUserChanged) {
        if(event.user == null){
          emit(AuthState.unauthenticated());
          print('emitted AuthState is unauthenticated.');
        }
        else{
          emit(AuthState.authenticated(user: event.user!));
          print('emitted AuthState is authenticated.');
        }
      } else if (event is AuthLogoutRequested) {
        await _authRepository.logout();
        FlutterBranchSdk.logout();
      }
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
