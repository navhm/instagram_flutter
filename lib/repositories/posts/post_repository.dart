import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/config/paths.dart';
import 'package:instagram_flutter/models/comment.dart';
import 'package:instagram_flutter/models/post_model.dart';
import 'package:instagram_flutter/repositories/repositories.dart';

class PostsRepository extends BasePostsRepository {
  final FirebaseFirestore _firebaseFirestore;

  PostsRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost({required Post post}) async {
    await _firebaseFirestore.collection(Paths.posts).add(post.toDocument());
  }

  @override
  Future<void> createComment({required Comment comment}) async {
    await _firebaseFirestore
        .collection(Paths.comments)
        .doc(comment.postId)
        .collection(Paths.postComments)
        .add(comment.toDocument());
  }

  @override
  Future<Post?> getPostById ({required String postId}) async {
    final postDoc = await _firebaseFirestore.collection(Paths.posts).doc(postId).get();
    return postDoc.exists ? Post.fromDocument(postDoc) : null;
  }

//TODO: check this Future<Post?>
//Why dont we need to use async for this???
  @override
  Stream<List<Future<Post?>>> getUserPosts({required String userId}) {
    final authorRef = _firebaseFirestore.collection(Paths.users).doc(userId);
    return _firebaseFirestore
        .collection(Paths.posts)
        .where('author', isEqualTo: authorRef)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromDocument(doc)).toList());
  }

  @override
  Stream<List<Future<Comment?>>> getPostComments({required String postId}) {
    return _firebaseFirestore
        .collection(Paths.comments)
        .doc(postId)
        .collection(Paths.postComments)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }

  @override
  Future<List<Post?>> getUserFeed(
      {required String userId, String? lastPostId}) async {
    QuerySnapshot postsSnap;
    if (lastPostId == null) {
      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('dateTime', descending: true)
          .limit(5)
          .get();
    } else {
      final lastPostDoc = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .doc(lastPostId)
          .get();

      if (!lastPostDoc.exists) {
        return [];
      }

      postsSnap = await _firebaseFirestore
          .collection(Paths.feeds)
          .doc(userId)
          .collection(Paths.userFeed)
          .orderBy('dateTime', descending: true)
          .startAfterDocument(lastPostDoc)
          .limit(5)
          .get();
    }

    final posts = Future.wait(
        postsSnap.docs.map((doc) => Post.fromDocument(doc)).toList());
    return posts;
  }

  @override
  Future<Set<String>> getLikedPostIds(
      {required String userId, required List<Post?> posts}) async {
    final postIds = <String>{};
    for (final post in posts) {
      final likedDoc = await _firebaseFirestore
          .collection(Paths.likes)
          .doc(post!.id)
          .collection(Paths.postLikes)
          .doc(userId)
          .get();
      if (likedDoc.exists) {
        postIds.add(post.id!);
      }
    }
    return postIds;
  }

  @override
  void likePost({required Post post, required String userId}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(post.id)
        .update({'likes': FieldValue.increment(1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(post.id)
        .collection(Paths.postLikes)
        .doc(userId)
        .set({});
  }

  @override
  void unlikePost({required String postId, required String userId}) {
    _firebaseFirestore
        .collection(Paths.posts)
        .doc(postId)
        .update({'likes': FieldValue.increment(-1)});

    _firebaseFirestore
        .collection(Paths.likes)
        .doc(postId)
        .collection(Paths.postLikes)
        .doc(userId)
        .delete();
  }
}
