import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<File?> pickImageFromGallery({
    required BuildContext context,
    required CropStyle cropStyle,
    required String title,
  }) async {
    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          cropStyle: cropStyle,
          compressQuality: 70,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: title,
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(),
          ]);
          return File(croppedFile!.path);
    }
    return null;
  }
}
