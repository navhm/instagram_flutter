// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, error }

class LoginState extends Equatable {
  final String email;
  final String password;
  final LoginStatus loginStatus;
  final Failure failure;

  const LoginState(
      {required this.email, required this.password, required this.loginStatus, required this.failure});

  factory LoginState.initial(){
    return const LoginState(email: '', password: '', loginStatus: LoginStatus.initial, failure: Failure());
  }

  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  // factory LoginState.submitting(String email, String password){
  //   return LoginState(email: email, password: password, loginStatus: LoginStatus.submitting);
  // }

  @override
  List<Object> get props => [email, password, loginStatus];

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? loginStatus,
    Failure? failure,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      loginStatus: loginStatus ?? this.loginStatus,
      failure: failure ?? this.failure,
    );
  }
}
