part of 'signup_cubit.dart';

enum SignUpStatus { initial, submitting, success, error }

class SignupState extends Equatable {
  final String username;
  final String email;
  final String password;
  final SignUpStatus signUpStatus;
  final Failure failure;

  const SignupState(
      {required this.username, required this.email, required this.password, required this.signUpStatus, required this.failure});

  factory SignupState.initial(){
    return const SignupState(username: '', email: '', password: '', signUpStatus: SignUpStatus.initial, failure: Failure());
  }

  bool get isFormValid => username.isNotEmpty && email.isNotEmpty && password.isNotEmpty;

  @override
  List<Object> get props => [username, email, password, signUpStatus];

  SignupState copyWith({
    String? username,
    String? email,
    String? password,
    SignUpStatus? signUpStatus,
    Failure? failure,
  }) {
    return SignupState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      signUpStatus: signUpStatus ?? this.signUpStatus,
      failure: failure ?? this.failure,
    );
  }
}

