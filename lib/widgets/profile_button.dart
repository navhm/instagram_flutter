import 'package:flutter/material.dart';
import 'package:instagram_flutter/screens/profile/edit_profile_screen.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    Key? key,
    required this.isCurrentUser,
    required this.isFollowing,
  }) : super(key: key);

  final bool isCurrentUser;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      //enable disable based on state of form
      onPressed: () {
        isCurrentUser ? Navigator.of(context).pushNamed(EditProfileScreen.routeName, arguments: EditProfileScreenArgs(context: context)) : null;
      },
      style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.blue[100],
          backgroundColor:
              isCurrentUser || !isFollowing ? Colors.blue : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          )),
      child: Text(
        isCurrentUser
            ? 'Edit Profile'
            : isFollowing
                ? 'Unfollow'
                : 'Follow',
        style: TextStyle(
          color: isCurrentUser || !isFollowing
              ? Colors.white
              : Colors.black, // Text color
        ),
      ),
    );
  }
}
