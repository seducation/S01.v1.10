import 'package:appwrite/models.dart' as models;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_app/lens_screen/staggered_grid_algorithm.dart';
import 'package:my_app/webview_screen.dart';

class LensStaggeredGrid extends StatelessWidget {
  final List<models.Row> items;
  final ScrollController scrollController;
  final bool isLoading;
  final String? error;

  const LensStaggeredGrid({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoading,
    this.error,
  });

  void _launchUrl(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: $error'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(4.0),
      sliver: SliverGrid(
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          pattern: StaggeredGridAlgorithm.getPattern(),
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          final isBigTile = (index % 3) == 0;
          return GestureDetector(
            onTap: () {
              if (item.data['link'] != null) {
                // Using 'link' field
                _launchUrl(context, item.data['link']);
              }
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.data['imageUrl'] != null)
                    Expanded(
                      child: CachedNetworkImage(
                        imageUrl: item.data['imageUrl'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  if (item.data['title'] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.data['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (item.data['description'] != null && !isBigTile)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        item.data['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          );
        }, childCount: items.length),
      ),
    );
  }
}
