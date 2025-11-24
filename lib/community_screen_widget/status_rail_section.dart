import 'package:flutter/material.dart';
import 'poster_item.dart';
import 'package:shimmer/shimmer.dart';

class StatusRailSection extends StatelessWidget {
  final String title;
  final List<PosterItem> items;
  final bool isLoading;

  const StatusRailSection({
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: isLoading ? 5 : items.length,
            itemBuilder: (context, index) {
              if (isLoading) {
                return const ShimmerCirclePlaceholder();
              }
              final item = items[index];
              return StatusItemWidget(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class StatusItemWidget extends StatelessWidget {
  final PosterItem item;

  const StatusItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(item.imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
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
            baseColor: Colors.grey.shade900,
            highlightColor: Colors.grey.shade700,
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade900,
            highlightColor: Colors.grey.shade700,
            child: Container(
              width: 60,
              height: 10,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
