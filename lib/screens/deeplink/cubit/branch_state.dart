// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'branch_cubit.dart';

enum DeeplinkStatus { initial, loading, loaded, error }

class BranchState extends Equatable {
  const BranchState(
      {required this.post,
      required this.product,
      required this.status,
      required this.failure});

  final Post? post;
  final Product? product;
  final DeeplinkStatus status;
  final Failure failure;

  factory BranchState.initial() {
    return const BranchState(
        post: null,
        product: null,
        status: DeeplinkStatus.initial,
        failure: Failure());
  }

  @override
  List<Object?> get props => [post, product, status, failure];

  

  BranchState copyWith({
    Post? post,
    Product? product,
    DeeplinkStatus? status,
    Failure? failure,
  }) {
    return BranchState(
      post : post ?? this.post,
      product: product ?? this.product,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
