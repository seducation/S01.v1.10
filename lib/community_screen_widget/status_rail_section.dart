import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/auth_service.dart';
import 'package:my_app/model/profile.dart';
import 'package:my_app/model/story.dart';
import 'package:my_app/story_view_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class StatusRailSection extends StatefulWidget {
  final String title;

  const StatusRailSection({super.key, required this.title});

  @override
  State<StatusRailSection> createState() => _StatusRailSectionState();
}

class _StatusRailSectionState extends State<StatusRailSection> {
  bool _isLoading = true;
  List<Profile> _profilesWithStories = [];
  Map<String, List<Story>> _storiesMap = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final authService = context.read<AuthService>();
      final appwriteService = context.read<AppwriteService>();
      final user = await authService.getCurrentUser();

      if (user != null && mounted) {
        // Fetch current user's own profiles (all types)
        final userProfilesResponse = await appwriteService.getUserProfiles(
          ownerId: user.id,
        );
        final userProfiles = userProfilesResponse.rows
            .map((row) => Profile.fromRow(row))
            .toList();

        // Fetch profiles of users the current persona is following
        final activeId = authService.activeIdentityId;
        final followingProfilesResponse = await appwriteService
            .getFollowingProfiles(
              followerId: activeId,
              userId: activeId == null ? user.id : null,
            );
        final followedProfiles = followingProfilesResponse.rows
            .map((row) => Profile.fromRow(row))
            .toList();

        // Combine all profiles, using a map to remove duplicates just in case
        final allProfilesMap = <String, Profile>{};
        for (var profile in userProfiles) {
          allProfilesMap[profile.id] = profile;
        }
        for (var profile in followedProfiles) {
          allProfilesMap[profile.id] = profile;
        }
        final allProfiles = allProfilesMap.values.toList();

        // Create a list of all profile IDs to fetch stories for
        final profileIds = allProfiles.map((p) => p.id).toList();

        // Fetch all stories if there are any profiles
        if (profileIds.isNotEmpty) {
          final storiesResponse = await appwriteService.getStories(profileIds);
          final allStories = storiesResponse.rows
              .map((row) => Story.fromRow(row))
              .toList();

          // Group stories by profile ID
          final storiesMap = <String, List<Story>>{};
          for (final story in allStories) {
            storiesMap.putIfAbsent(story.profileId, () => []).add(story);
          }
          _storiesMap = storiesMap;

          // Filter the combined list of profiles to only include those with stories
          _profilesWithStories = allProfiles
              .where(
                (profile) =>
                    _storiesMap.containsKey(profile.id) &&
                    _storiesMap[profile.id]!.isNotEmpty,
              )
              .toList();
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (_isLoading)
                  const ShimmerCirclePlaceholder()
                else
                  // Dedicated "Add to Story" button
                  AddToStoryWidget(
                    onTap: () {
                      context.go('/add_to_story');
                    },
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5, // Placeholder count
                          itemBuilder: (context, index) =>
                              const ShimmerCirclePlaceholder(),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _profilesWithStories.length,
                          itemBuilder: (context, index) {
                            final profile = _profilesWithStories[index];
                            final stories = _storiesMap[profile.id] ?? [];
                            return StatusItemWidget(
                              profile: profile,
                              stories: stories,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// A simple widget for the "Add to Story" button
class AddToStoryWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AddToStoryWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(radius: 35, backgroundColor: Colors.grey),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Add to Story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusItemWidget extends StatelessWidget {
  final Profile profile;
  final List<Story> stories;

  const StatusItemWidget({
    super.key,
    required this.profile,
    required this.stories,
  });

  @override
  Widget build(BuildContext context) {
    final appwriteService = context.read<AppwriteService>();
    return GestureDetector(
      onTap: () {
        if (stories.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  StoryViewScreen(stories: stories, profile: profile),
            ),
          );
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: profile.profileImageUrl != null
                  ? NetworkImage(
                      appwriteService.getFileViewUrl(profile.profileImageUrl!),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerCirclePlaceholder extends StatelessWidget {
  const ShimmerCirclePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(width: 60, height: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
