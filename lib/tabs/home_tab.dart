import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/post_detail_screen.dart';
import 'package:provider/provider.dart';

enum PostType { text, image, video }

class User {
  final String name;
  final String avatarUrl;

  User({
    required this.name,
    required this.avatarUrl,
  });
}

class Post {
  final String id;
  final User author;
  final DateTime timestamp;
  final String? mediaUrl;
  final String caption;
  final PostType type;

  Post({
    required this.id,
    required this.author,
    required this.timestamp,
    this.mediaUrl,
    required this.caption,
    required this.type,
  });
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late AppwriteService _appwriteService;
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _appwriteService = context.read<AppwriteService>();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final postsResponse = await _appwriteService.getPosts();
      final posts = await Future.wait(postsResponse.rows.map((row) async {
        final authorProfile =
            await _appwriteService.getProfile(row.data['profile_id']);
        
        final profileImageUrl = authorProfile.data['profileImageUrl'];
        final author = User(
          name: authorProfile.data['name'],
          avatarUrl: profileImageUrl != null && profileImageUrl.isNotEmpty
              ? _appwriteService.getFileViewUrl(profileImageUrl)
              : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        );

        final fileIdsData = row.data['file_ids'];
        final List<String> fileIds = fileIdsData is List ? List<String>.from(fileIdsData.map((id) => id.toString())) : [];

        String? postTypeString = row.data['type'];
        if (postTypeString == null && fileIds.isNotEmpty) {
          postTypeString = 'image'; // Infer type for old data
        }
        final postType = _getPostType(postTypeString);

        String? mediaUrl;

        if (fileIds.isNotEmpty) {
          if (postType == PostType.image) {
            mediaUrl = _appwriteService.getFileViewUrl(fileIds.first);
          } else if (postType == PostType.video) {
            mediaUrl = _appwriteService.getFileThumbnailUrl(fileIds.first);
          }
        }

        return Post(
          id: row.$id,
          author: author,
          timestamp: DateTime.tryParse(row.data['timestamp'] ?? '') ?? DateTime.now(),
          mediaUrl: mediaUrl,
          caption: row.data['caption'],
          type: postType,
        );
      }));

      // Filter for posts that have images and sort them.
      final imagePosts = posts.where((p) => p.mediaUrl != null).toList();
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
          _error = e.toString();
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
            : _error != null
                ? Center(
                    child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];

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
                              imageUrl: post.mediaUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.white),
                              errorWidget: (context, url, error) {
                                debugPrint("Grid Image Error for url $url: $error");
                                return Container(color: Colors.red.withAlpha(128));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ));
  }
}
