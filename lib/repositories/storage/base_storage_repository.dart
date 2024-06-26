import 'dart:io';

abstract class BaseStorageRepository {
  Future<String> uploadProfileImage({required String url, required File image});
  Future<String> uploadPost({required File image});
}
