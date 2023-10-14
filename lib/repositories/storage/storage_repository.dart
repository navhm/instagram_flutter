import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_flutter/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

class StorageRepository extends BaseStorageRepository {
  late final FirebaseStorage _firebaseStorage;

  StorageRepository({FirebaseStorage? firebaseStorage})
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<String> _uploadImage(
      {required String ref, required File image}) async {
    final downloadUrl = await _firebaseStorage
        .ref(ref)
        .putFile(image)
        .then((taskSnapshot) => taskSnapshot.ref.getDownloadURL());
    return downloadUrl;
  }

  @override
  Future<String> uploadProfileImage(
      {required String url, required File image}) async {
    var imageId = const Uuid().v4();

    if (url.isNotEmpty) {
      final exp = RegExp(r'userProfile_(.*).jpg');
      imageId = exp.firstMatch(url)![1]!;
    }

    final downloadUrl = await _uploadImage(
        ref: 'images/users/userProfile_$imageId.jpg', image: image);
    return downloadUrl;
  }

  @override
  Future<String> uploadPost({required File image}) async {
    final imageId = const Uuid().v4();
    final downloadUrl =
        await _uploadImage(ref: 'images/posts/post_$imageId.jpg', image: image);
    return downloadUrl;
  }
}
