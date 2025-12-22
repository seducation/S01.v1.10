import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:my_app/model/profile.dart';
import 'package:my_app/post_detail_screen.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  final String profileId;
  const HomeTab({super.key, required this.profileId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late AppwriteService _appwriteService;
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appwriteService = context.read<AppwriteService>();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final results = await Future.wait([
        _appwriteService.getPostsFromUsers([widget.profileId]),
        _appwriteService.getProfiles(),
      ]);
      final postsResponse = results[0];
      final profilesResponse = results[1];
      final profilesMap = {
        for (var doc in profilesResponse.rows) doc.$id: doc.data
      };
      final posts = postsResponse.rows.map((row) {
        final profileIds = row.data['profile_id'] as List?;
        final profileId = (profileIds?.isNotEmpty ?? false) ? profileIds!.first as String? : null;
        if (profileId == null) return null;

        final creatorProfileData = profilesMap[profileId];
        if (creatorProfileData == null) {
          return null;
        }

        final author = Profile.fromMap(creatorProfileData, profileId);

        final fileIdsData = row.data['file_ids'];
        final List<String> fileIds =
            fileIdsData is List ? List<String>.from(fileIdsData.map((id) => id.toString())) : [];
        String? postTypeString = row.data['type'];
        if (postTypeString == null && fileIds.isNotEmpty) {
          postTypeString = 'image';
        }
        final postType = _getPostType(postTypeString);
        List<String> mediaUrls = [];
        if (fileIds.isNotEmpty) {
          if (postType == PostType.image || postType == PostType.video) {
            mediaUrls = fileIds.map((id) => _appwriteService.getFileViewUrl(id)).toList();
          }
        }
        return Post(
            id: row.$id,
            author: author,
            timestamp: DateTime.tryParse(row.data['timestamp'] ?? '') ?? DateTime.now(),
            mediaUrls: mediaUrls,
            contentText: row.data['caption'],
            type: postType,
            stats: PostStats());
      }).where((post) => post != null).cast<Post>().toList();
      final imagePosts = posts.where((p) => p.mediaUrls?.isNotEmpty ?? false).toList();
      imagePosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (mounted) {
        setState(() {
          _posts = imagePosts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  PostType _getPostType(String? type) {
    switch (type) {
      case 'image':
        return PostType.image;
      case 'video':
        return PostType.video;
      default:
        return PostType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                if (post.mediaUrls == null || post.mediaUrls!.isEmpty) {
                  return Container(color: Colors.grey[800]);
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: GridTile(
                      footer: post.type == PostType.video
                          ? const GridTileBar(
                              backgroundColor: Colors.black45,
                              trailing: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                              ),
                            )
                          : null,
                      child: CachedNetworkImage(
                        imageUrl: post.mediaUrls!.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.white),
                        errorWidget: (context, url, error) {
                          return Container(color: Colors.grey[900]);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
