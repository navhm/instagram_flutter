import 'package:instagram_flutter/models/models.dart';

abstract class BasePostsRepository {
  Future<void> createPost({required Post post});
  Future<void> createComment({required Comment comment});
  Stream<List<Future<Post?>>> getUserPosts({required String userId});
  Stream<List<Future<Comment?>>> getPostComments({required String postId});
}