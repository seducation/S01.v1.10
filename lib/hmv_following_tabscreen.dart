import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';

import './widgets/post_item.dart';
import 'model/profile.dart';

class HMVFollowingTabscreen extends StatefulWidget {
  const HMVFollowingTabscreen({super.key});

  @override
  State<HMVFollowingTabscreen> createState() => _HMVFollowingTabscreenState();
}

class _HMVFollowingTabscreenState extends State<HMVFollowingTabscreen> {
  late AppwriteService appwriteService;
  List<Post>? _posts;
  bool _isLoading = true;
  String? _error;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    appwriteService = context.read<AppwriteService>();
    _fetchFollowingPosts();
  }

  Future<void> _fetchFollowingPosts() async {
    try {
      final user = await appwriteService.getUser();
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }
      final profiles = await appwriteService.getUserProfiles(ownerId: user.$id);
      if(profiles.rows.isNotEmpty){
         _profileId = profiles.rows.first.$id;
      }

      final followingProfiles = await appwriteService.getFollowingProfiles(userId: user.$id);
      if (followingProfiles.rows.isEmpty) {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
        return;
      }

      final profileIds = followingProfiles.rows.map((profile) => profile.$id).toList();

      final postsResponse = await appwriteService.getPostsFromUsers(profileIds);

      final profilesResponse = await appwriteService.getProfiles();
      final profilesMap = {for (var p in profilesResponse.rows) p.$id: Profile.fromMap(p.data, p.$id)};

      final posts = postsResponse.rows.map((row) {
        final profileId = row.data['profile_id'] as String?;
        final author = profilesMap[profileId];

        if (author == null) {
          return null;
        }

        PostType type = PostType.text;
        String? mediaUrl;
        final fileIds = row.data['file_ids'] as List?;
        if (fileIds != null && fileIds.isNotEmpty) {
          type = PostType.image;
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

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } on AppwriteException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text('Error: $_error'),
      );
    }

    if (_posts == null || _posts!.isEmpty) {
      return const Center(
        child: Text('No posts from the users you follow.'),
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
