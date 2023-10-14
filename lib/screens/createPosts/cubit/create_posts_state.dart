part of 'create_posts_cubit.dart';

enum CreatePostStatus { initial, submitting, success, error }

class CreatePostsState extends Equatable {
  const CreatePostsState(
      {required this.imageFile,
      required this.caption,
      required this.status,
      required this.failure});

  factory CreatePostsState.initial() {
    return const CreatePostsState(
        imageFile: null,
        caption: '',
        status: CreatePostStatus.initial,
        failure: Failure());
  }

  final File? imageFile;
  final String caption;
  final CreatePostStatus status;
  final Failure failure;

  @override
  List<Object?> get props => [imageFile, caption, status, failure];

  CreatePostsState copyWith({
    File? imageFile,
    String? caption,
    CreatePostStatus? status,
    Failure? failure,
  }) {
    return CreatePostsState(
      imageFile: imageFile ?? this.imageFile,
      caption: caption ?? this.caption,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
