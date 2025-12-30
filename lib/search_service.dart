import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:my_app/model/profile.dart'; // Needed for Post constructor mocks if strict, or just use dummy
import 'package:my_app/services/search_algorithm.dart';

class SearchService {
  final AppwriteService _appwriteService;

  SearchService(this._appwriteService);

  Future<List<Map<String, dynamic>>> search(String query) async {
    final results = await Future.wait([
      _appwriteService.searchProfiles(query: query),
      _appwriteService.searchPosts(query: query),
    ]);

    final profiles = results[0].rows.map((row) {
      final data = row.data;
      data['\$id'] = row.data['\$id'];
      // Basic profile score based on name match
      double score = 0.0;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final q = query.toLowerCase();
      if (name == q)
        score = 2.0;
      else if (name.startsWith(q))
        score = 1.5;
      else if (name.contains(q))
        score = 1.0;

      return {'type': 'profile', 'data': data, 'score': score};
    }).toList();

    final posts = results[1].rows.map((row) {
      final data = row.data;
      data['\$id'] = row.data['\$id'];

      // Convert to Post object for scoring
      // Minimal mapping required for SearchAlgorithm
      final post = Post(
        id: data['\$id'],
        author: Profile(
          id: '',
          ownerId: '',
          name: '',
          type: 'profile',
          createdAt: DateTime.now(),
        ), // Dummy
        timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
        contentText: data['caption'] ?? '',
        linkTitle: data['titles'] ?? '',
        stats: PostStats(
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          shares: data['shares'] ?? 0,
          views: data['views'] ?? 0,
        ),
        tags: (data['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );

      final score = SearchAlgorithm.calculateScore(post, query);

      return {'type': 'post', 'data': data, 'score': score};
    }).toList();

    final allResults = [...profiles, ...posts];

    // mixed sort by score
    allResults.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    return allResults;
  }
}
