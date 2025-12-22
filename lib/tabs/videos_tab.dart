import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:my_app/model/profile.dart';
import 'package:my_app/widgets/post_item.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideosTab extends StatefulWidget {
  final String profileId;
  const VideosTab({super.key, required this.profileId});
  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  late AppwriteService _appwriteService;
  List<Post> _videoPosts = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _appwriteService = context.read<AppwriteService>();
    _loadVideoPosts();
  }

  Future<void> _loadVideoPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await Future.wait([
        _appwriteService.getPostsFromUsers([widget.profileId]),
        _appwriteService.getProfiles(),
      ]);

      final postsResponse = results[0];
      final profilesResponse = results[1];

      final profilesMap = {for (var doc in profilesResponse.rows) doc.$id: doc.data};

      final posts = postsResponse.rows.map((row) {
        final creatorProfileData = profilesMap[row.data['profile_id']];
        if (creatorProfileData == null) return null;

        final author = Profile.fromMap(creatorProfileData, row.data['profile_id']);

        final updatedAuthor = Profile(
          id: author.id,
          name: author.name,
          type: author.type,
          bio: author.bio,
          profileImageUrl: author.profileImageUrl != null && author.profileImageUrl!.isNotEmpty
              ? _appwriteService.getFileViewUrl(author.profileImageUrl!)
              : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
          ownerId: author.ownerId,
          createdAt: author.createdAt,
        );

        final fileIdsData = row.data['file_ids'];
        final List<String> fileIds = fileIdsData is List ? List<String>.from(fileIdsData.map((id) => id.toString())) : [];

        String? postTypeString = row.data['type'];
        final postType = _getPostType(postTypeString);

        String? mediaUrl;

        if (fileIds.isNotEmpty) {
            mediaUrl = _appwriteService.getFileViewUrl(fileIds.first);
        }

        final postStats = PostStats(
          likes: row.data['likes'] ?? 0,
          comments: row.data['comments'] ?? 0,
          shares: row.data['shares'] ?? 0,
          views: row.data['views'] ?? 0,
        );

        return Post(
          id: row.$id,
          author: updatedAuthor,
          timestamp: DateTime.tryParse(row.data['timestamp'] ?? '') ?? DateTime.now(),
          contentText: row.data['caption'] ?? '',
          mediaUrl: mediaUrl,
          type: postType,
          stats: postStats,
        );
      }).where((post) => post != null && post.type == PostType.video).cast<Post>().toList();
      
      if (!mounted) return;
      setState(() {
        _videoPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  PostType _getPostType(String? type) {
    switch (type) {
      case 'image':
        return PostType.image;
      case 'video':
      case 'mp4':
      case 'movie':
        return PostType.video;
      default:
        return PostType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _videoPosts.isEmpty
            ? const Center(child: Text("No videos found"))
            : ListView.builder(
                itemCount: _videoPosts.length,
                itemBuilder: (context, index) {
                  final post = _videoPosts[index];
                  return VisibilityDetector(
                    key: Key(post.id),
                    onVisibilityChanged: (visibilityInfo) {
                      var visiblePercentage = visibilityInfo.visibleFraction * 100;
                      if (visiblePercentage > 50) {
                        // Autoplay logic can be implemented here
                      }
                    },
                    child: PostItem(post: post, profileId: widget.profileId),
                  );
                },
              );
  }
}
