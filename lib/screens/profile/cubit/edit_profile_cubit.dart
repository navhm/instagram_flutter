import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/blocs/blocs.dart';
import 'package:instagram_flutter/models/failure_model.dart';
import 'package:instagram_flutter/repositories/repositories.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;
  final ProfileBloc _profileBloc;
  EditProfileCubit(
      {required StorageRepository storageRepository,
      required UserRepository userRepository,
      required ProfileBloc profileBloc})
      : _storageRepository = storageRepository,
        _userRepository = userRepository,
        _profileBloc = profileBloc,
        super(EditProfileState.initial()) {
    final user = _profileBloc.state.user;
    emit(state.copyWith(userName: user!.username, bio: user.bio));
  }

  void usernameChanged(String value) {
    emit(state.copyWith(userName: value, status: EditProfileStatus.initial));
  }

  void bioChanged(String value) {
    emit(state.copyWith(bio: value, status: EditProfileStatus.initial));
  }

  void profileImageChanged(File file) {
    emit(state.copyWith(image: file, status: EditProfileStatus.initial));
  }

  void submit() async {
    emit(state.copyWith(status: EditProfileStatus.submitting));
    try {
      final currentUser = _profileBloc.state.user;
      var profileImageUrl = currentUser!.profileImageUrl;

      if (state.image != null) {
        profileImageUrl = await _storageRepository.uploadProfileImage(
            url: profileImageUrl, image: state.image!);
      }
      final updatedUser = currentUser.copyWith(
          username: state.userName,
          bio: state.bio,
          profileImageUrl: profileImageUrl);

      await _userRepository.updateUser(user: updatedUser);

      print('User updated successfully');

      _profileBloc.add(ProfileLoadUser(userId: currentUser.id));
      emit(state.copyWith(status: EditProfileStatus.success));
    } catch (error) {
      emit(state.copyWith(
          status: EditProfileStatus.error,
          failure: const Failure(message: 'Unable to update profile')));
    }
  }
}
