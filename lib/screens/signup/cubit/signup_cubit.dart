import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/models/models.dart';

import '../../../repositories/repositories.dart';

part 'signup_state.dart';

class SignUpCubit extends Cubit<SignupState> {
  SignUpCubit({required AuthRepository authRepository}) : _authRepository = authRepository, super(SignupState.initial());

  final AuthRepository _authRepository;

  void usernameChnaged(String value){
    emit(state.copyWith(username: value, signUpStatus: SignUpStatus.initial));
  }

  void emailChanged(String value){
    emit(state.copyWith(email: value, signUpStatus: SignUpStatus.initial));
  }

  void passwordChanged(String value){
    emit(state.copyWith(password: value, signUpStatus: SignUpStatus.initial));
  }

  void signUpWithCredentials() async {
    if(!state.isFormValid || state.signUpStatus == SignUpStatus.submitting){
      return;
    }
    emit(state.copyWith(signUpStatus: SignUpStatus.submitting));
    try{
      await _authRepository.signUpWithEmailAndPassword(userName: state.username, email: state.email, password: state.password);
      emit(state.copyWith(signUpStatus: SignUpStatus.success));
    } on Failure catch(error){
      emit(state.copyWith(signUpStatus: SignUpStatus.error, failure: Failure(code: error.code, message: error.message)));
    }
  }
}
