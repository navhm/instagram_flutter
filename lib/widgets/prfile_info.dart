import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key, required this.username, required this.bio});

  final String username;
  final String bio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(username, style: const TextStyle(fontWeight: FontWeight.bold),),
        const SizedBox(
          height: 8,
        ),
        Text(bio),
        const Divider(),
      ],
    );
  }
}