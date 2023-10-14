import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:instagram_flutter/blocs/blocs.dart';
import 'package:instagram_flutter/helpers/image_helper.dart';
import 'package:instagram_flutter/models/user_model.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:instagram_flutter/screens/profile/cubit/edit_profile_cubit.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/login_form.dart';
import 'package:instagram_flutter/widgets/user_profile_image.dart';

class EditProfileScreenArgs {
  final BuildContext context;

  const EditProfileScreenArgs({
    required this.context,
  });
}

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key, required this.user});

  static const String routeName = '/edit_profile';

  static Route getRoute({required EditProfileScreenArgs args}) {
    return MaterialPageRoute(
        builder: (context) => BlocProvider<EditProfileCubit>(
            create: (_) => EditProfileCubit(
                storageRepository: context.read<StorageRepository>(),
                userRepository: context.read<UserRepository>(),
                profileBloc: args.context.read<ProfileBloc>()),
            child: EditProfileScreen(
              user: args.context.read<ProfileBloc>().state.user!,
            )),
        settings: const RouteSettings(name: routeName));
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.success) {
          Navigator.of(context).pop();
        } else if (state.status == EditProfileStatus.error) {
          showDialog(
              context: context,
              builder: (context) =>
                  ErrorDialog(content: state.failure.message!));
        }
      },
      builder: (context, state) {
        return Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              GestureDetector(
                  onTap: () => _selectProfileImage(context),
                  child: UserProfileImage(
                    radius: 80.0,
                    profileImageUrl: user.profileImageUrl,
                    profileImage: state.image,
                  )),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                            initialValue:
                                user.username.isNotEmpty ? user.username : null,
                            hint: 'Username',
                            isPasswordField: false,
                            onChnaged: (value) => context
                                .read<EditProfileCubit>()
                                .usernameChanged(value!),
                            validator: (value) => value!.isEmpty
                                ? 'Username cannot be empty'
                                : null),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomTextField(
                            initialValue: user.bio.isNotEmpty ? user.bio : null,
                            hint: 'Bio',
                            isPasswordField: false,
                            onChnaged: (value) => context
                                .read<EditProfileCubit>()
                                .bioChanged(value!),
                            validator: null),
                        const SizedBox(
                          height: 25,
                        ),
                        ElevatedButton(
                          onPressed: () => _submit(context,
                              state.status == EditProfileStatus.submitting),
                          style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.blue[100],
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                          child: const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white, // Text color
                            ),
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
        ));
      },
    );
  }

  void _selectProfileImage(BuildContext context) async {
    final newProfileImage = await ImageHelper.pickImageFromGallery(
        context: context, cropStyle: CropStyle.circle, title: 'Profile Image');
    /*added context.mounted for Don't use 'BuildContext's across async gaps.
        Try rewriting the code to not reference the 'BuildContext'.
        */
    if (newProfileImage != null && context.mounted) {
      context.read<EditProfileCubit>().profileImageChanged(newProfileImage);
    }
  }

  void _submit(BuildContext context, bool isSubmitting) {
    if (_formkey.currentState!.validate() && !isSubmitting) {
      context.read<EditProfileCubit>().submit();
    }
  }
}
