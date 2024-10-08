import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_flutter/extensions/extensions.dart';
import 'package:instagram_flutter/models/models.dart';
import 'package:instagram_flutter/screens/comments/comments_screen.dart';
import 'package:instagram_flutter/screens/profile/profile_screen.dart';
import 'package:instagram_flutter/widgets/user_profile_image.dart';

class PostView extends StatelessWidget {
  const PostView(
      {super.key,
      required this.post,
      required this.isLiked,
      required this.onLike,
      this.recentlyLiked = false});

  final Post post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName,
                  arguments: ProfileScreenArgs(userId: post.author.id));
              //navigate to the user profile
            },
            child: Row(
              children: [
                UserProfileImage(
                    radius: 18.0, profileImageUrl: post.author.profileImageUrl),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    post.author.username,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: onLike,
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height / 2.25,
            width: double.infinity,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onLike,
              icon: isLiked
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(Icons.favorite_outline),
            ),
            Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.rotationY(pi), // Rotate 180 degrees horizontally
              child: IconButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  CommentsScreen.routeName,
                  arguments: CommentsScreenArgs(post: post),
                ),
                icon: const FaIcon(
                  FontAwesomeIcons.comment,
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${recentlyLiked ? post.likes + 1 : post.likes} likes',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '${post.author.username}  ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: post.caption,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
              Text(
                post.dateTime.getTimeAgo(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
