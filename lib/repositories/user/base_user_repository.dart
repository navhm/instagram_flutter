import 'package:instagram_flutter/models/user_model.dart';

abstract class BaseUserRepository {
  Future<User> getUserById({required String userId});

  Future<void> updateUser({required User user});
}