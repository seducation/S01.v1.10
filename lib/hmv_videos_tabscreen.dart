import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:provider/provider.dart';

import 'widgets/post_item.dart';
import 'model/profile.dart';

class HMVVideosTabscreen extends StatefulWidget {
  const HMVVideosTabscreen({super.key});

  @override
  State<HMVVideosTabscreen> createState() => _HMVVideosTabscreenState();
}

class _HMVVideosTabscreenState extends State<HMVVideosTabscreen> {
  late AppwriteService appwriteService;
  List<Post>? _posts;
  bool _isLoading = true;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    appwriteService = context.read<AppwriteService>();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final user = await appwriteService.getUser();
      if(user != null){
        final profiles = await appwriteService.getUserProfiles(ownerId: user.$id);
        if(profiles.rows.isNotEmpty){
           _profileId = profiles.rows.first.$id;
        }
      }
      final postsResponse = await appwriteService.getPosts();
      final profilesResponse = await appwriteService.getProfiles();

      final profilesMap = {for (var p in profilesResponse.rows) p.$id: Profile.fromMap(p.data, p.$id)};

      final posts = postsResponse.rows.map((row) {
        final profileId = row.data['profile_id'] as String?;
        final author = profilesMap[profileId];

        if (author == null) {
          return null;
        }

        PostType type;
        try {
          type = PostType.values.firstWhere((e) => e.toString() == 'PostType.${row.data['type']}');
        } catch (e) {
          type = PostType.text; 
        }

        if (type != PostType.video) {
          return null;
        }

        String? mediaUrl;
        final fileIds = row.data['file_ids'] as List?;
        if (fileIds != null && fileIds.isNotEmpty) {
          mediaUrl = appwriteService.getFileViewUrl(fileIds.first);
        }

        return Post(
          id: row.$id,
          author: author,
          timestamp: DateTime.tryParse(row.data['timestamp'] ?? '') ?? DateTime.now(),
          linkTitle: row.data['titles'] as String? ?? '',
          contentText: row.data['caption'] as String? ?? '',
          type: type,
          mediaUrl: mediaUrl,
          linkUrl: row.data['linkUrl'] as String?,
          stats: PostStats(
            likes: row.data['likes'] ?? 0,
            comments: row.data['comments'] ?? 0,
            shares: row.data['shares'] ?? 0,
            views: row.data['views'] ?? 0,
          ),
        );
      }).whereType<Post>().toList();

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_posts == null || _posts!.isEmpty) {
      return const Center(
        child: Text("No videos available."),
      );
    }

    return ListView.builder(
      itemCount: _posts!.length,
      itemBuilder: (context, index) {
        final post = _posts![index];
        return PostItem(post: post, profileId: _profileId ?? '');
      },
    );
  }
}