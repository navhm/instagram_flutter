import 'package:instagram_flutter/models/user_model.dart';

abstract class BaseUserRepository {
  Future<User> getUserById({required String userId});

  Future<void> updateUser({required User user});

  Future<List<User>?> searchUsers({required String query});

  void followUser({required String userId, required String followUserId});

  void unFollowUser({required String userId, required String unFollowUserId});

  Future<bool> isFollowing(
      {required String userId, required String otherUserId});
}
