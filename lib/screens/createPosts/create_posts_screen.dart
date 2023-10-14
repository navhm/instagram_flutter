import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:instagram_flutter/helpers/image_helper.dart';
import 'package:instagram_flutter/screens/createPosts/cubit/create_posts_cubit.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/login_form.dart';

class CreatePostsScreen extends StatelessWidget {
  CreatePostsScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: BlocConsumer<CreatePostsCubit, CreatePostsState>(
        listener: (context, state) {
          if (state.status == CreatePostStatus.success) {
            _formKey.currentState?.reset();
            context.read<CreatePostsCubit>().reset();

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Post uploaded successfully'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.green,
            ));
          } else if (state.status == CreatePostStatus.error) {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message!));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
              child: Column(
            children: [
              GestureDetector(
                onTap: () => _selectPostImage(context),
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: state.imageFile != null
                      ? Image.file(state.imageFile!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 120,
                        ),
                ),
              ),
              if (state.status == CreatePostStatus.submitting)
                const LinearProgressIndicator(),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextField(
                        initialValue: null,
                        hint: 'Caption',
                        isPasswordField: false,
                        onChnaged: (value) => context
                            .read<CreatePostsCubit>()
                            .postCaptionChanged(caption: value!),
                        validator: (value) => value!.trim().isEmpty
                            ? 'Caption cannot be empty'
                            : null,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () => _submit(context, state.imageFile,
                            state.status == CreatePostStatus.submitting),
                        style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.blue[100],
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                        child: const Text(
                          'Create Post',
                          style: TextStyle(
                            color: Colors.white, // Text color
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ));
        },
      ),
    );
  }

  void _selectPostImage(BuildContext context) async {
    try {
      final postImage = await ImageHelper.pickImageFromGallery(
          context: context, cropStyle: CropStyle.rectangle, title: 'Create ');
      if (postImage != null && context.mounted) {
        context
            .read<CreatePostsCubit>()
            .postImageChanged(file: postImage);
      }
    } catch (error) {
      print('Select image issue: ${error}');
    }
  }

  void _submit(BuildContext context, File? image, bool isSubmitting) {
    if (_formKey.currentState!.validate() && !isSubmitting && image != null) {
      context.read<CreatePostsCubit>().createPost();
    }
  }
}
