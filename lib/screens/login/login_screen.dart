import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:instagram_flutter/screens/login/cubit/login_cubit.dart';
import 'package:instagram_flutter/screens/signup/sign_up_screen.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  static const String routeName = '/login_screen';

  static Route getRoute() {
    return PageRouteBuilder(
        pageBuilder: (conext, _, __) => BlocProvider<LoginCubit>(
            create: (_) =>
                LoginCubit(authRepository: conext.read<AuthRepository>()),
            child: LoginScreen()),
        settings: const RouteSettings(name: routeName));
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          print('login listener triggered');
          switch (state.loginStatus) {
            case LoginStatus.initial:
              //idk
              break;
            case LoginStatus.submitting:
              //show loader
              break;
            case LoginStatus.success:
              //navigate to nav_screen
              break;
            case LoginStatus.error:
              //TODO: this is temporary
              String errorMessage = '';
              if (state.failure.code == "INVALID_LOGIN_CREDENTIALS") {
                errorMessage = "User does not exist. Please Sign up.";
              }
              //display error
              showDialog(
                  context: context,
                  builder: (context) => ErrorDialog(
                        content: errorMessage,
                      ));
              break;
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Instagram',
                          style: TextStyle(
                              fontFamily: 'Billabong',
                              fontSize: 60.0,
                              fontWeight: FontWeight.w100),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                          initialValue: null,
                          hint: 'Email',
                          isPasswordField: false,
                          onChnaged: (value) =>
                              context.read<LoginCubit>().emailChanged(value!),
                          validator: (value) => !value!.contains('@')
                              ? 'Please enter valid email.'
                              : null,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomTextField(
                            initialValue: null,
                            hint: 'Password',
                            isPasswordField: true,
                            onChnaged: (value) => context
                                .read<LoginCubit>()
                                .passwordChanged(value!),
                            validator: (value) => value!.length < 6
                                ? 'Password should be atleast 6 characters'
                                : null),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: BlocBuilder<LoginCubit, LoginState>(
                              buildWhen: (previous, current) =>
                                  previous.isFormValid != current.isFormValid,
                              builder: (context, builerState) => ElevatedButton(
                                    //enable disable based on state of form
                                    onPressed: builerState.isFormValid
                                        ? () => _submitForm(
                                            context,
                                            builerState.loginStatus ==
                                                LoginStatus.submitting)
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                        disabledBackgroundColor:
                                            Colors.blue[100],
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        )),
                                    child: const Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                      ),
                                    ),
                                  )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  const Divider(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(SignUpScreen.routeName),
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey, // Change text color
                            ),
                          ),
                          TextSpan(
                            text: 'Sign up.',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formkey.currentState!.validate() && !isSubmitting) {
      context.read<LoginCubit>().loginWithCredentials();
    }
  }
}
