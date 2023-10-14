// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_profile_cubit.dart';

enum EditProfileStatus{ initial, submitting, success, error}

class EditProfileState extends Equatable {
  const EditProfileState(this.userName, this.bio, this.image, this.status, this.failure);
  
  final String? userName;
  final String? bio;
  final File? image;
  final EditProfileStatus status;
  final Failure failure;

  factory EditProfileState.initial (){
    return const EditProfileState('', '', null, EditProfileStatus.initial, Failure() );
  }

  @override
  List<Object?> get props => [userName, bio, image, status, failure];
  

  EditProfileState copyWith({
    String? userName,
    String? bio,
    File? image,
    EditProfileStatus? status,
    Failure? failure,
  }) {
    return EditProfileState(
      userName ?? this.userName,
      bio ?? this.bio,
      image ?? this.image,
      status ?? this.status,
      failure ?? this.failure,
    );
  }
}
