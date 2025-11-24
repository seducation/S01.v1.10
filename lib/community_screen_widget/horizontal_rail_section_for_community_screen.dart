import 'package:flutter/material.dart';
import 'poster_item.dart';
import 'shimmer_poster_placeholder_community_screen.dart';
import 'poster_widget_community_screen.dart';

class HorizontalSection extends StatelessWidget {
  final String title;
  final List<PosterItem> items;
  final bool isLoading;

  const HorizontalSection({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: isLoading ? 6 : items.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (isLoading) return const PosterShimmer();
              return PosterCard(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}
