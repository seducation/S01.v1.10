import 'dart:math';
import 'package:my_app/model/post.dart';

class SearchAlgorithm {
  // Weights for final score calculation
  static const double _weightRelevance = 0.6;
  static const double _weightEngagement = 0.3;
  static const double _weightRecency = 0.1;

  /// Ranks a list of posts based on the query.
  static List<Post> rankPosts(List<Post> posts, String query) {
    if (query.isEmpty) return posts;

    final scoredPosts = posts.map((post) {
      final score = calculateScore(post, query);
      return MapEntry(post, score);
    }).toList();

    // Sort descending by score
    scoredPosts.sort((a, b) => b.value.compareTo(a.value));

    return scoredPosts.map((entry) => entry.key).toList();
  }

  /// Calculates the intelligent score for a single post.
  static double calculateScore(Post post, String query) {
    final relevanceScore = _calculateRelevance(post, query.toLowerCase());
    final engagementScore = _calculateEngagement(post);
    final recencyScore = _calculateRecency(post.timestamp);

    // Normalize scores to 0-1 range before weighting is ideal,
    // but here we ensure internal calculations stay reasonable.
    // Engagement is logarithmic, Recency is 0-1, Relevance is 0-1.

    // Normalize engagement (assuming max reasonable engagement for normalization)
    // We treat > 1000 interactions as "max" for the sake of 0-1 normalization relative to peer posts
    // or just rely on log scale. Here we stick to the weighted sum.

    return (relevanceScore * _weightRelevance) +
        (engagementScore * _weightEngagement) +
        (recencyScore * _weightRecency);
  }

  static double _calculateRelevance(Post post, String query) {
    double score = 0.0;
    final lowerQuery = query.toLowerCase();

    // 1. Exact Title Match
    if ((post.linkTitle ?? '').toLowerCase().contains(lowerQuery)) {
      score += 1.0;
    }

    // 2. Caption Match
    final caption = post.contentText.toLowerCase();
    if (caption.contains(lowerQuery)) {
      score += 0.8;
    }

    // 2.5 Tags Match
    if (post.tags != null) {
      for (final tag in post.tags!) {
        if (tag.toLowerCase().contains(lowerQuery)) {
          score += 1.2; // High relevance for tags
          break; // Count once per query
        }
      }
    }

    // 3. Typo Tolerance / Fuzzy Match (Token based)
    final queryTokens = lowerQuery.split(' ');
    final contentTokens = caption.split(' ')
      ..addAll((post.linkTitle ?? '').toLowerCase().split(' '));

    int matchCount = 0;
    for (final qToken in queryTokens) {
      for (final cToken in contentTokens) {
        if (_calculateLevenshteinDistance(qToken, cToken) <= 2) {
          // 2 edit distance
          // Partial match bonus, less than exact match
          matchCount++;
          break; // Match found for this query token
        }
      }
    }

    if (matchCount > 0) {
      score += (matchCount / queryTokens.length) * 0.5;
    }

    // Cap relevance at 1.0 for normalization purposes
    return min(score, 1.0);
  }

  static double _calculateEngagement(Post post) {
    // Logarithmic scale prevents viral posts from overpowering everything.
    // Score = log10(1 + interactions)
    // Interactions = likes + comments*2 + shares*3 + views*0.1
    final interactions =
        post.stats.likes +
        (post.stats.comments * 2) +
        (post.stats.shares * 3) +
        (post.stats.views * 0.1);

    if (interactions <= 0) return 0.0;

    // Normalize: Log10 of 10000 is 4. Let's map 0-10000+ to 0-1.
    final logScore = log(1 + interactions) / log(10);
    // Assuming 5 (100k interactions) is a high reasonable max for this app scale.
    return min(logScore / 5.0, 1.0);
  }

  static double _calculateRecency(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp).inDays;

    // Decay function: 1 / (1 + days)
    // 0 days old -> score 1.0
    // 7 days old -> score 0.125
    return 1.0 / (1.0 + difference);
  }

  // Basic Levenshtein implementation for typo tolerance
  static int _calculateLevenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }
}
