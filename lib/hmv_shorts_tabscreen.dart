import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:my_app/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/comments_screen.dart';
import 'dart:math';

import 'model/profile.dart';
import 'package:video_player/video_player.dart';

double calculateScore(Post post) {
  final hoursSincePosted = DateTime.now().difference(post.timestamp).inHours;
  final score = ((post.stats.likes * 1) + (post.stats.comments * 5) + (post.stats.shares * 10)) /
      pow(hoursSincePosted + 2, 1.5);
  return score;
}

class HMVShortsTabscreen extends StatefulWidget {
  const HMVShortsTabscreen({super.key});

  @override
  State<HMVShortsTabscreen> createState() => _HMVShortsTabscreenState();
}

class _HMVShortsTabscreenState extends State<HMVShortsTabscreen> {
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await appwriteService.getUser();
      if (user != null) {
        final profiles = await appwriteService.getUserProfiles(
          ownerId: user.$id,
        );
        if (profiles.rows.isNotEmpty) {
          _profileId = profiles.rows.first.$id;
        }
      }

      final results = await Future.wait([
        appwriteService.getPosts(),
        appwriteService.getProfiles(),
      ]);

      final postsResponse = results[0];
      final profilesResponse = results[1];

      final profilesMap = {
        for (var doc in profilesResponse.rows) doc.$id: doc.data,
      };

      final postFutures = postsResponse.rows.map((row) async {

        final profileIds = row.data['profile_id'] as List?;
        if (profileIds == null || profileIds.isEmpty) {
          return null;
        }
        final profileId = profileIds.first as String?;
        if (profileId == null) {
          return null;
        }

        final creatorProfileData = profilesMap[profileId];
        if (creatorProfileData == null) {
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
                  ? appwriteService.getFileViewUrl(author.profileImageUrl!)
                  : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
          ownerId: author.ownerId,
          createdAt: author.createdAt,
        );

        final originalAuthorIds = row.data['author_id'] as List?;
        final originalAuthorId = (originalAuthorIds?.isNotEmpty ?? false)
            ? originalAuthorIds!.first as String?
            : null;

        Profile? originalAuthor;
        if (originalAuthorId != null && originalAuthorId != profileId) {
          final originalAuthorProfileData = profilesMap[originalAuthorId];
          if (originalAuthorProfileData != null) {
            originalAuthor = Profile.fromMap(
              originalAuthorProfileData,
              originalAuthorId,
            );
          }
        }

        final fileIdsData = row.data['file_ids'];
        final List<String> fileIds = fileIdsData is List
            ? List<String>.from(fileIdsData.map((id) => id.toString()))
            : [];

        List<String> mediaUrls = [];
        if (fileIds.isNotEmpty) {
          mediaUrls = fileIds
              .map((id) => appwriteService.getFileViewUrl(id))
              .toList();
        }

        String? postTypeString = row.data['type'];
        final postType = await _getPostType(postTypeString, row.data['linkUrl'], fileIds);

        final postStats = PostStats(
          likes: row.data['likes'] ?? 0,
          comments: row.data['comments'] ?? 0,
          shares: row.data['shares'] ?? 0,
          views: row.data['views'] ?? 0,
        );

        return Post(
          id: row.$id,
          author: updatedAuthor,
          originalAuthor: originalAuthor,
          timestamp:
              DateTime.tryParse(row.data['timestamp'] ?? '') ??
                  DateTime.now(),
          contentText: row.data['caption'] ?? '',
          mediaUrls: mediaUrls,
          type: postType,
          stats: postStats,
          linkUrl: row.data['linkUrl'],
          linkTitle: row.data['titles'],
          authorIds: (row.data['author_id'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          profileIds: (row.data['profile_id'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
        );
      });

      final posts = (await Future.wait(postFutures))
          .whereType<Post>()
          .where((post) => post.type == PostType.video)
          .toList();

      if (!mounted) return;

      _rankPosts(posts);

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error fetching data in HMVShortsTabscreen: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<PostType> _getPostType(String? type, String? linkUrl, List<String> fileIds) async {
    if (type == 'video') {
      return PostType.video;
    }
    if (fileIds.isNotEmpty) {
      try {
        final file = await appwriteService.getFile(fileIds.first);
        if (file.mimeType.startsWith('video/')) {
          return PostType.video;
        }
        return PostType.image;
      } catch (e) {
        debugPrint('Error fetching file metadata: $e');
        return PostType.image; // Assume image if metadata fetch fails
      }
    }
    if (linkUrl != null && linkUrl.isNotEmpty) {
      return PostType.linkPreview;
    }
    return PostType.text;
  }

  void _rankPosts(List<Post> posts) {
    for (var post in posts) {
      post.score = calculateScore(post);
    }
    posts.sort((a, b) => b.score.compareTo(a.score));
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
        child: Text("No shorts available."),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _posts!.length,
      itemBuilder: (context, index) {
        final post = _posts![index];
        return ShortsPage(
          post: post,
          profileId: _profileId ?? '',
        );
      },
    );
  }
}

class ShortsPage extends StatefulWidget {
  final Post post;
  final String profileId;

  const ShortsPage({super.key, required this.post, required this.profileId});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  late bool _isLiked;
  late int _likeCount;
  int _commentCount = 0;
  late AppwriteService _appwriteService;
  SharedPreferences? _prefs;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _appwriteService = context.read<AppwriteService>();
    _isLiked = false;
    _likeCount = widget.post.stats.likes;
    _commentCount = widget.post.stats.comments;
    _initializeState();

    if (widget.post.mediaUrls != null && widget.post.mediaUrls!.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrls!.first))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller?.play();
            _controller?.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeState() async {
    _prefs = await SharedPreferences.getInstance();
    _fetchCommentCount();
    if (mounted) {
      setState(() {
        _isLiked = _prefs?.getBool(widget.post.id) ?? false;
      });
    }
  }

  Future<void> _fetchCommentCount() async {
    try {
      final comments = await _appwriteService.getComments(widget.post.id);
      if (mounted) {
        setState(() {
          _commentCount = comments.total;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _toggleLike() async {
    if (_prefs == null) return;

    final user = await _appwriteService.getUser();
    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You must be logged in to like posts.'),
      ));
      return;
    }

    final newLikedState = !_isLiked;
    final newLikeCount = newLikedState ? _likeCount + 1 : _likeCount - 1;

    if (mounted) {
      setState(() {
        _isLiked = newLikedState;
        _likeCount = newLikeCount;
      });
    }

    try {
      await _appwriteService.updatePostLikes(
          widget.post.id, newLikeCount, widget.post.timestamp.toIso8601String());
      await _prefs!.setBool(widget.post.id, newLikedState);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = !newLikedState;
          _likeCount = _isLiked ? newLikeCount + 1 : newLikeCount - 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }
  
  void _openComments() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(post: widget.post),
      ),
    );

    if (result == true) {
      _fetchCommentCount();
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: GestureDetector(
      onTap: () {
        if (_controller != null) {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          _controller != null && _controller!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : Container(color: Colors.black, child: const Center(child: CircularProgressIndicator())),
          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(153, 0, 0, 0), Colors.transparent, const Color.fromARGB(153, 0, 0, 0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // UI elements
          _buildUiOverlay(),
        ],
      ),
    ),
  );
}

  Widget _buildUiOverlay() {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 32, top: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section (optional, e.g., for 'Shorts' title or close button)
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             // Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30)
            ],
          ),
          // Bottom section with post info and actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildPostInfo(),
              ),
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePageScreen(profileId: widget.post.author.id)),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(widget.post.author.profileImageUrl!),
              ),
              const SizedBox(width: 10),
              Text(
                widget.post.author.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.post.contentText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(_likeCount),
          onTap: _toggleLike,
          color: _isLiked ? Colors.red : Colors.white,
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.comment_bank_outlined,
          label: _formatCount(_commentCount),
          onTap: _openComments,
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.reply,
          label: _formatCount(widget.post.stats.shares),
        ),
         const SizedBox(height: 20),
        _buildActionButton(
          icon: Icons.more_horiz,
          label: 'More',
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, VoidCallback? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: color ?? Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
