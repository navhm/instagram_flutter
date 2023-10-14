import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/models/failure_model.dart';
import 'package:instagram_flutter/repositories/auth/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository authRepository}) : _authRepository = authRepository, super(LoginState.initial());

  final AuthRepository _authRepository;

  void emailChanged(String value){
    emit(state.copyWith(email: value, loginStatus: LoginStatus.initial));
  }

  void passwordChanged(String value){
    emit(state.copyWith(password: value, loginStatus: LoginStatus.initial));
  }

  void loginWithCredentials() async {
    if(!state.isFormValid || state.loginStatus == LoginStatus.submitting){
      return;
    }
    emit(state.copyWith(loginStatus: LoginStatus.submitting));
    try{
      await _authRepository.loginWithEmailAndPassword(email: state.email, password: state.password);
      emit(state.copyWith(loginStatus: LoginStatus.success));
    } on Failure catch(error){
      emit(state.copyWith(loginStatus: LoginStatus.error, failure: Failure(code: error.code, message: error.message)));
    }
  }
}
