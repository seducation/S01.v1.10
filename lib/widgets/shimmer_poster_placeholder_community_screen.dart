import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PosterShimmer extends StatelessWidget {
  const PosterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade700,
      child: Container(
        width: 140,
        height: 210,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
