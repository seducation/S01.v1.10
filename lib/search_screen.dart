import 'dart:async';

import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/appwrite_service.dart';

class SearchScreen extends StatefulWidget {
  final String? query;
  final AppwriteService appwriteService;

  const SearchScreen({super.key, this.query, required this.appwriteService});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<models.Row> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      _searchController.text = widget.query!;
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      _isLoading = true;
    });
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isNotEmpty) {
        _fetchSuggestions(_searchController.text);
      } else {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final results = await widget.appwriteService.searchPosts(query: query);
      setState(() {
        _suggestions = results.rows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, maybe show a snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching suggestions: $e')),
      );
    }
  }

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      context.go('/search/$query');
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
              child: _buildSuggestionsList(),
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
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface.withAlpha(153)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(153), fontSize: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: _submitSearch,
            ),
          ),
          IconButton(
            onPressed: () {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice search action')),
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
                const SnackBar(content: Text('Camera search action')),
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

    if (_searchController.text.isEmpty) {
      return const Center(
          child: Text('Enter a search term to see suggestions.'));
    }

    if (_suggestions.isEmpty) {
      return const Center(child: Text('No suggestions found.'));
    }

    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        return _buildSuggestionItem(_suggestions[index]);
      },
    );
  }

  Widget _buildSuggestionItem(models.Row suggestion) {
    final theme = Theme.of(context);
    final title =
        suggestion.data['titles'] ?? suggestion.data['caption'] ?? 'No title';

    return InkWell(
      onTap: () {
        _submitSearch(title);
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
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
