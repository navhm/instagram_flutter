import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/signup/cubit/signup_cubit.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/login_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/repositories/repositories.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  static const String routeName = '/signup_screen';

  static Route getRoute() {
    return MaterialPageRoute(
        builder: (conext) => BlocProvider<SignUpCubit>(
            create: (_) =>
                SignUpCubit(authRepository: conext.read<AuthRepository>()),
            child: SignUpScreen()),
        settings: const RouteSettings(name: routeName));
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignupState>(
      listener: (context, state) {
        switch (state.signUpStatus) {
          case SignUpStatus.initial:
            //idk
            break;
          case SignUpStatus.submitting:
            //show loader
            break;
          case SignUpStatus.success:
            //navigate to nav_screen
            break;
          case SignUpStatus.error:
            //display error
            showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                      content: state.failure.message!,
                    ));
        }
      },
      builder: (context, state) {
        return Scaffold(
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
                          hint: 'Username',
                          isPasswordField: false,
                          onChnaged: (value) => context
                              .read<SignUpCubit>()
                              .usernameChnaged(value!),
                          validator: (value) => value!.length < 5
                              ? 'Username should be atleast 5 characters'
                              : null,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomTextField(
                          initialValue: null,
                          hint: 'Email',
                          isPasswordField: false,
                          onChnaged: (value) =>
                              context.read<SignUpCubit>().emailChanged(value!),
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
                                .read<SignUpCubit>()
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
                          child: ElevatedButton(
                            onPressed: state.isFormValid
                                ? () => _submitForm(
                                    context,
                                    state.signUpStatus ==
                                        SignUpStatus.submitting)
                                : null, // Button is initially disabled
                            style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: Colors.blue[100],
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Column(
              //   children: [
              //     const Divider(
              //       height: 30,
              //     ),
              //     RichText(
              //       text: TextSpan(
              //         children: <TextSpan>[
              //           const TextSpan(
              //             text: 'Don\'t have an account? ',
              //             style: TextStyle(
              //               fontSize: 10,
              //               color: Colors.grey, // Change text color
              //             ),
              //           ),
              //           TextSpan(
              //             text: 'Sign up.',
              //             style: TextStyle(
              //               fontSize: 10,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.blue[800],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     const SizedBox(
              //       height: 20,
              //     )
              //   ],
              // )
            ],
          ),
        );
      },
    );
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formkey.currentState!.validate() && !isSubmitting) {
      context.read<SignUpCubit>().signUpWithCredentials();
    }
  }
}
