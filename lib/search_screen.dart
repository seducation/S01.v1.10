import 'dart:async';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/appwrite_service.dart';
import 'package:my_app/model/post.dart';
import 'package:my_app/model/profile.dart';
import 'package:my_app/services/search_algorithm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  final String? query;
  final AppwriteService appwriteService;

  const SearchScreen({super.key, this.query, required this.appwriteService});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // Search State
  List<models.Row> _rawSuggestions = [];
  List<models.Row> _rankedSuggestions = []; // For quick suggest, maybe simple
  bool _isLoading = false;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    if (widget.query != null) {
      _searchController.text = widget.query!;
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      if (_searchController.text.isNotEmpty) {
        _isLoading = true;
      }
    });

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isNotEmpty) {
        _fetchSuggestions(_searchController.text);
      } else {
        setState(() {
          _rawSuggestions = [];
          _rankedSuggestions = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      // Basic Appwrite search
      final results = await widget.appwriteService.searchPosts(query: query);

      // Client-side Ranking for Suggestions
      // Note: We need full Post objects to use SearchAlgorithm fully,
      // but searchPosts returns models.Row. We'll map them temporarily or just rank by text match for suggestions.
      // For true 'intelligent' search we usually do this on the results page,
      // but let's try to order suggestions intelligently too if possible.

      // Since models.Row isn't exactly Post, we do a lightweight rank here or just show basic results.
      // Let's just filter/sort basic suggestions by simple text match for responsiveness.
      // The heavy lifting is done in ResultsSearches.

      if (!mounted) return;

      setState(() {
        _rawSuggestions = results.rows;
        // Client-side Ranking using SearchAlgorithm
        _rankedSuggestions = List.from(_rawSuggestions);

        // Cache scores to avoid recalculating in sort comparison (though lightweight enough here)
        final scores = <String, double>{};

        for (final row in _rankedSuggestions) {
          final data = row.data;
          final post = Post(
            id: row.$id,
            author: Profile(
              id: '',
              ownerId: '',
              name: '',
              type: 'profile',
              createdAt: DateTime.now(),
            ), // Dummy
            timestamp:
                DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
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
          scores[row.$id] = SearchAlgorithm.calculateScore(post, query);
        }

        _rankedSuggestions.sort((a, b) {
          final scoreA = scores[a.$id] ?? 0.0;
          final scoreB = scores[b.$id] ?? 0.0;
          return scoreB.compareTo(scoreA); // Descending score
        });

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching suggestions: $e')));
    }
  }

  void _addToHistory(String query) {
    setState(() {
      if (_searchHistory.contains(query)) {
        _searchHistory.remove(query);
      }
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    });
    _saveSearchHistory();
  }

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      _addToHistory(query);
      context.push('/search/$query');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context),
            Divider(height: 1, color: theme.dividerColor),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildHistoryList()
                  : _buildSuggestionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                  fontSize: 18,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: _submitSearch,
            ),
          ),
          IconButton(
            onPressed: () {
              // Placeholder for future Voice Search implementation
              // Could integrate speech_to_text package here
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice search coming soon')),
              );
            },
            icon: const Icon(Icons.mic),
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera search coming soon')),
              );
            },
            icon: const Icon(Icons.camera_alt_outlined),
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_rankedSuggestions.isEmpty) {
      return const Center(child: Text('No suggestions found.'));
    }

    return ListView.builder(
      itemCount: _rankedSuggestions.length,
      itemBuilder: (context, index) {
        return _buildSuggestionItem(_rankedSuggestions[index]);
      },
    );
  }

  Widget _buildHistoryList() {
    if (_searchHistory.isEmpty) {
      return const Center(child: Text('No recent searches.'));
    }
    return ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final query = _searchHistory[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(query),
          onTap: () {
            _searchController.text = query;
            _submitSearch(query);
          },
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _searchHistory.removeAt(index);
              });
              _saveSearchHistory();
            },
          ),
        );
      },
    );
  }

  Widget _buildSuggestionItem(models.Row suggestion) {
    final theme = Theme.of(context);
    final title =
        suggestion.data['titles'] ?? suggestion.data['caption'] ?? 'No title';
    // Clean up title for display if it's very long
    final displayTitle = title.toString().trim().replaceAll('\n', ' ');

    return InkWell(
      onTap: () {
        _submitSearch(displayTitle);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: _highlightOccurrences(
                    displayTitle,
                    _searchController.text,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _highlightOccurrences(String source, String query) {
    if (query.isEmpty) return [TextSpan(text: source)];

    final matches = <TextSpan>[];
    String sourceLower = source.toLowerCase();
    String queryLower = query.toLowerCase();

    int lastMatchEnd = 0;
    int index = sourceLower.indexOf(queryLower);

    while (index != -1) {
      if (index > lastMatchEnd) {
        matches.add(TextSpan(text: source.substring(lastMatchEnd, index)));
      }
      matches.add(
        TextSpan(
          text: source.substring(index, index + query.length),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      lastMatchEnd = index + query.length;
      index = sourceLower.indexOf(queryLower, lastMatchEnd);
    }

    if (lastMatchEnd < source.length) {
      matches.add(TextSpan(text: source.substring(lastMatchEnd)));
    }

    return matches;
  }
}
