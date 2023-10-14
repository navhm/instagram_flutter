import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserProfileImage extends StatelessWidget {
  const UserProfileImage(
      {super.key,
      required this.radius,
      required this.profileImageUrl,
      this.profileImage});

  final double radius;
  final String? profileImageUrl;
  final File? profileImage;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: getProfileImage(),
      child: getProfilePlaceholder(),
    );
  }

  Icon? getProfilePlaceholder(){
    print('getProfilePlaceholder profileImageUrlCheck: $profileImageUrl');
    if(profileImage == null && profileImageUrl == null){
      return Icon(Icons.account_circle, color: Colors.grey[400], size: radius * 2,);
    }
    else if(profileImageUrl!.isEmpty){
      return Icon(Icons.account_circle, color: Colors.grey[400], size: radius * 2,);
    }
    return null;
  }

  ImageProvider? getProfileImage (){
    print('getProfileImage profileImageUrlCheck: $profileImageUrl');
    if(profileImage != null){
      return FileImage(profileImage!);
    }
    else if(profileImageUrl != null && profileImageUrl!.isNotEmpty){
      return CachedNetworkImageProvider(profileImageUrl!);
    }
    return null;
  }
}
