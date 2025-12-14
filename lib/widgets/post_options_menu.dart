import 'package:flutter/material.dart';
import 'package:my_app/auth_service.dart';
import 'package:my_app/model/post.dart';
import 'package:my_app/widgets/add_to_playlist.dart';
import 'package:provider/provider.dart';

class PostOptionsMenu extends StatelessWidget {
  final Post post;
  final String profileId;

  const PostOptionsMenu(
      {super.key, required this.post, required this.profileId});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isOwner = authService.currentUser?.id == post.author.ownerId;

    return IconButton(
      icon: Icon(Icons.more_horiz, color: Colors.grey[600], size: 22),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView(
              shrinkWrap: true,
              children: [
                const ListTile(
                  title: Text('Post Setting',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const ListTile(
                  leading: Icon(Icons.high_quality),
                  title: Text('Quality Setting'),
                ),
                const ListTile(
                  leading: Icon(Icons.translate),
                  title: Text('Translate and Transcript'),
                ),
                if (isOwner) ...[
                  const Divider(),
                  const ListTile(
                    title: Text('Owner Setting',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add),
                    title: const Text('Add to Playlist'),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) => AddToPlaylistScreen(
                          postId: post.id,
                          profileId: profileId,
                        ),
                      );
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ],
                const Divider(),
                const ListTile(
                  title: Text('Caution',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const ListTile(
                  leading: Icon(Icons.not_interested),
                  title: Text('Not Interested'),
                ),
                const ListTile(
                  leading: Icon(Icons.warning),
                  title: Text('NSFW Content'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
