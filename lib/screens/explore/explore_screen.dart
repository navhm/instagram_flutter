import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram_flutter/screens/explore/cubit/search_cubit.dart';
import 'package:instagram_flutter/screens/profile/profile_screen.dart';
import 'package:instagram_flutter/widgets/centred_text.dart';
import 'package:instagram_flutter/widgets/user_profile_image.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoTextField(
          controller: _textEditingController,
          suffix: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<SearchCubit>().clearSearch();
              _textEditingController.clear();
            },
          ),
          placeholder: 'Search users',
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<SearchCubit>().searchUsers(value);
            }
          },
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          switch (state.searchStatus) {
            case SearchStatus.error:
              return CentredText(text: state.failure.message!);
            case SearchStatus.loading:
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              );
            case SearchStatus.loaded:
              return state.users.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return ListTile(
                          leading: UserProfileImage(
                            profileImageUrl: user.profileImageUrl,
                            radius: 22.0,
                          ),
                          title: Text(
                            user.username,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          onTap: () => Navigator.of(context).pushNamed(
                              ProfileScreen.routeName,
                              arguments: ProfileScreenArgs(userId: user.id)),
                        );
                      },
                      itemCount: state.users.length,
                    )
                  : const CentredText(text: 'No users found.');
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
