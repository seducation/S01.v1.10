import 'package:flutter/material.dart';
import 'package:my_app/poster_item.dart';

class PosterCard extends StatelessWidget {
  final PosterItem item;

  const PosterCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
