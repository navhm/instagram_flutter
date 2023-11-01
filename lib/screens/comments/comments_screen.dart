import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/blocs/auth/auth_bloc.dart';

import 'package:instagram_flutter/models/post_model.dart';
import 'package:instagram_flutter/repositories/posts/post_repository.dart';
import 'package:instagram_flutter/screens/comments/bloc/comments_bloc.dart';
import 'package:instagram_flutter/screens/screens.dart';
import 'package:instagram_flutter/widgets/error_dialog.dart';
import 'package:instagram_flutter/widgets/user_profile_image.dart';
import 'package:intl/intl.dart';

class CommentsScreenArgs {
  final Post post;
  const CommentsScreenArgs({
    required this.post,
  });
}

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  static const String routeName = '/comments_screen';

  static Route getRoute({required CommentsScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<CommentsBloc>(
        create: (_) => CommentsBloc(
          postsRepository: context.read<PostsRepository>(),
          authBloc: context.read<AuthBloc>(),
        )..add(
            FetchComments(post: args.post),
          ),
        child: const CommentsScreen(),
      ),
    );
  }

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentsBloc, CommentsState>(
      listener: (context, state) {
        if (state.status == CommentsStatus.error) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(content: state.failure.message!),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Comments'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.only(bottom: 60.0),
            itemCount: state.comments.length,
            itemBuilder: (BuildContext context, int index) {
              final comment = state.comments[index];
              return ListTile(
                leading: UserProfileImage(
                  radius: 22.0,
                  profileImageUrl: comment!.author.profileImageUrl,
                ),
                title: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.author.username,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text: '    ',
                      ),
                      TextSpan(
                        text: comment.content,
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  DateFormat.yMd().add_jm().format(comment.dateTime),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => Navigator.of(context).pushNamed(
                  ProfileScreen.routeName,
                  arguments: ProfileScreenArgs(userId: comment.author.id),
                ),
              );
            },
          ),
          bottomSheet: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.status == CommentsStatus.submitting)
                  const LinearProgressIndicator(),
                Row(
                  children: [
                    Expanded(child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration.collapsed(hintText: 'Comment'),

                    ),),
                    IconButton(onPressed: () {
                      final content = _controller.text.trim();
                      if(content.isNotEmpty){
                        context.read<CommentsBloc>().add(PostComment(content: content));
                        _controller.clear();
                      }
                    }, icon: const Icon(Icons.send))
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
