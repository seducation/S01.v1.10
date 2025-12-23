import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:my_app/model/post.dart';
import 'model/profile.dart';
import 'widgets/post_item.dart';

double calculateScore(Post post) {
  final hoursSincePosted = DateTime.now().difference(post.timestamp).inHours;
  final score =
      ((post.stats.likes * 1) +
          (post.stats.comments * 5) +
          (post.stats.shares * 10)) /
      pow(hoursSincePosted + 2, 1.5);
  return score;
}

class HMVFeaturesTabscreen extends StatefulWidget {
  const HMVFeaturesTabscreen({super.key});

  @override
  State<HMVFeaturesTabscreen> createState() => _HMVFeaturesTabscreenState();
}

class _HMVFeaturesTabscreenState extends State<HMVFeaturesTabscreen> {
  late AppwriteService _appwriteService;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _appwriteService = context.read<AppwriteService>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final user = await _appwriteService.getUser();
      if (user != null) {
        final profiles = await _appwriteService.getUserProfiles(
          ownerId: user.$id,
        );
        if (profiles.rows.isNotEmpty) {
          _profileId = profiles.rows.first.$id;
        }
      }
      final postsResponse = await _appwriteService.getPosts();
      debugPrint(
        'HMVFeaturesTabscreen: Fetched ${postsResponse.rows.length} posts raw.',
      );
      final profilesResponse = await _appwriteService.getProfiles();
      debugPrint(
        'HMVFeaturesTabscreen: Fetched ${profilesResponse.rows.length} profiles.',
      );

      final profilesMap = {
        for (var p in profilesResponse.rows) p.$id: p.data,
      };

      final posts = postsResponse.rows
          .map((row) {
            final isHidden = row.data['isHidden'] as bool? ?? false;
            if (isHidden) {
              return null;
            }

            final profileIds = row.data['profile_id'] as List?;
            final profileId = (profileIds?.isNotEmpty ?? false)
                ? profileIds!.first as String?
                : null;
            
            if (profileId == null) {
              debugPrint(
                'HMVFeaturesTabscreen: Post ${row.$id} filtered. profileId is null.',
              );
              return null;
            }

            final creatorProfileData = profilesMap[profileId];

            if (creatorProfileData == null) {
              debugPrint(
                'HMVFeaturesTabscreen: Post ${row.$id} filtered. ProfileId: $profileId not found in profiles map.',
              );
              return null;
            }

            final author = Profile.fromMap(creatorProfileData, profileId);

            final updatedAuthor = Profile(
              id: author.id,
              name: author.name,
              type: author.type,
              bio: author.bio,
              profileImageUrl:
                  author.profileImageUrl != null &&
                      author.profileImageUrl!.isNotEmpty
                  ? _appwriteService.getFileViewUrl(author.profileImageUrl!)
                  : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
              ownerId: author.ownerId,
              createdAt: author.createdAt,
            );

            PostType type = PostType.text;
            List<String> mediaUrls = [];
            final fileIds = row.data['file_ids'] as List?;
            if (fileIds != null && fileIds.isNotEmpty) {
              type = PostType.image;
              mediaUrls = fileIds
                  .map((id) => _appwriteService.getFileViewUrl(id))
                  .toList();
            }

            return Post(
              id: row.$id,
              author: updatedAuthor,
              timestamp:
                  DateTime.tryParse(row.data['timestamp'] ?? '') ??
                  DateTime.now(),
              linkTitle: row.data['titles'] as String? ?? '',
              contentText: row.data['caption'] as String? ?? '',
              type: type,
              mediaUrls: mediaUrls,
              linkUrl: row.data['linkUrl'] as String?,
              stats: PostStats(
                likes: row.data['likes'] ?? 0,
                comments: row.data['comments'] ?? 0,
                shares: row.data['shares'] ?? 0,
                views: row.data['views'] ?? 0,
              ),
            );
          })
          .whereType<Post>()
          .toList();

      if (mounted) {
        debugPrint(
          'HMVFeaturesTabscreen: Setting state with ${posts.length} valid posts.',
        );
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
      _rankPosts();
    } catch (e, stackTrace) {
      debugPrint('Error fetching data in HMVFeaturesTabscreen: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _rankPosts() {
    for (var post in _posts) {
      post.score = calculateScore(post);
    }
    _posts.sort((a, b) => b.score.compareTo(a.score));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFeed(),
    );
  }

  Widget _buildFeed() {
    if (_posts.isEmpty) {
      return const Center(child: Text("No posts available."));
    }

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return PostItem(post: post, profileId: _profileId ?? '');
      },
    );
  }
}
