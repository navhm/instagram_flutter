import 'package:flutter/widgets.dart';
import 'package:instagram_flutter/widgets/profile_button.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats(
      {super.key,
      required this.posts,
      required this.followers,
      required this.following, required this.isCurrentUser, required this.isFollowing});

  final int posts;
  final String followers;
  final String following;
  final bool isCurrentUser;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stats(value: posts.toString(), label: 'Posts'),
            _Stats(value: followers, label: 'Followers'),
            _Stats(value: following, label: 'Following'),
          ],
        ),
        const SizedBox(
          height: 8,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ProfileButton(isCurrentUser: isCurrentUser, isFollowing: isFollowing),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value),
        Text(label),
      ],
    );
  }
}
