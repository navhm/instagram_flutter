import 'package:instagram_flutter/models/models.dart';

abstract class BasePostsRepository {
  Future<void> createPost({required Post post});
  Future<void> createComment({required Comment comment});
  Stream<List<Future<Post?>>> getUserPosts({required String userId});
  Stream<List<Future<Comment?>>> getPostComments({required String postId});
  Future<List<Post?>> getUserFeed({required String userId, String? lastPostId});

  void likePost({required Post post, required String userId});
  void unlikePost({required String postId, required String userId});
  Future<Set<String>> getLikedPostIds({required String userId, required List<Post?> posts});

}