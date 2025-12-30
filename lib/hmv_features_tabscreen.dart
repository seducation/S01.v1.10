import 'package:flutter/material.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/auth_service.dart';
import 'package:provider/provider.dart';

import 'package:my_app/model/post.dart' as model;
import 'package:my_app/model/profile.dart' as profile_model;
import 'widgets/post_item.dart';

// Feed imports
import 'features/feed/controllers/feed_controller.dart';
import 'features/feed/models/feed_item.dart' as feed_models;
import 'features/feed/models/post_item.dart' as feed_models;

class HMVFeaturesTabscreen extends StatefulWidget {
  const HMVFeaturesTabscreen({super.key});

  @override
  State<HMVFeaturesTabscreen> createState() => _HMVFeaturesTabscreenState();
}

class _HMVFeaturesTabscreenState extends State<HMVFeaturesTabscreen> {
  late FeedController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final appwriteService = context.read<AppwriteService>();
    final authService = context.read<AuthService>();

    _controller = FeedController(
      client: appwriteService.client,
      userId: authService.currentUser?.id ?? '',
      postType: 'all', // Fetch mixed feed
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _controller.loadFeed();
    }
  }

  model.Post? _convertToModelPost(feed_models.FeedItem item) {
    if (item is! feed_models.PostItem) return null;

    // Infer post type based on media presence for mixed feed
    model.PostType type = model.PostType.text;
    if (item.mediaUrls.isNotEmpty) {
      // Simple inference, ideally backend sends type.
      // For now default to image if media exists, logic can be refined.
      // Check extension if available in URL?
      // The cloud function stores 'type' in DB, but FeedItem might not expose it easily yet
      // unless we added it to FeedItem model.
      // Assuming FeedItem extraction logic:
      // If standard FeedController usage is adopted, we might need a precise type from backend.
      // For now, let's look at extensions in URLs or default to image/video if known.
      // Actually, FeedItem has 'mediaUrls'.
      // Let's assume 'image' for simplicity if media exists, or 'video' if we can guess.
      // For HMVFeatures, previously it did a fetch checks.
      // Let's rely on backend 'postType' if available?
      // FeedItem definition in prev context didn't show strict type field besides 'type' (post/ad/carousel).

      // Fallback: Check if any URL looks like video
      bool isVideo = item.mediaUrls.any(
        (url) => url.contains('.mp4') || url.contains('.mov'),
      );
      type = isVideo ? model.PostType.video : model.PostType.image;
    } else {
      // Check for files?
    }

    return model.Post(
      id: item.postId,
      author: profile_model.Profile(
        id: item.userId,
        name: item.username,
        type: 'profile',
        profileImageUrl: item.profileImage,
        ownerId: '',
        createdAt: DateTime.now(),
      ),
      timestamp: item.createdAt,
      contentText: item.content,
      type: type,
      mediaUrls: item.mediaUrls,
      stats: model.PostStats(
        likes: item.engagementScore,
        views: item.viewCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: Consumer<FeedController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.feedItems.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.feedItems.isEmpty) {
              if (controller.error != null) {
                return Center(child: Text('Error: ${controller.error}'));
              }
              return const Center(child: Text("No posts available."));
            }

            return RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: controller.feedItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.feedItems.length) {
                    return controller.isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox.shrink();
                  }

                  final item = controller.feedItems[index];
                  final post = _convertToModelPost(item);

                  if (post == null) return const SizedBox.shrink();

                  return PostItem(
                    post: post,
                    profileId: controller.userId,
                    heroTagPrefix: 'hmv_features',
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
