import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_grid.dart';
import '../grid/notices_grid.dart';
import '../grid/friends_grid.dart';
import '../grid/jobs_grid.dart';
import '../grid/services_grid.dart';
import '../grid/stories_grid.dart';

class CommunityFeed extends StatelessWidget {
  final List<Product> products;

  const CommunityFeed({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return CustomScrollView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      slivers: _buildFeedSlivers(context),
    );
  }

  List<Widget> _buildFeedSlivers(BuildContext context) {
    List<Widget> slivers = [];
    List<Product> currentProductBatch = [];

    for (int i = 0; i < products.length; i++) {
      currentProductBatch.add(products[i]);
      int indexPlusOne = i + 1;

      // Check if we reached an injection point (10, 20, 30) or end of list
      if (indexPlusOne % 10 == 0 || indexPlusOne == products.length) {
        // Add current batch of products as a grid
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.all(10.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    ProductCard(product: currentProductBatch[index]),
                childCount: currentProductBatch.length,
              ),
            ),
          ),
        );

        // Inject secondary widget if we hit the exact intervals
        if (indexPlusOne == 10) {
          slivers.add(const SliverToBoxAdapter(child: NoticesGridWidget()));
        } else if (indexPlusOne == 20) {
          slivers.add(const SliverToBoxAdapter(child: FriendsGridWidget()));
        } else if (indexPlusOne == 30) {
          slivers.add(const SliverToBoxAdapter(child: JobsGridWidget()));
        } else if (indexPlusOne == 40) {
          slivers.add(const SliverToBoxAdapter(child: ServicesGridWidget()));
        } else if (indexPlusOne == 50) {
          slivers.add(const SliverToBoxAdapter(child: StoriesGridWidget()));
        }

        // Reset batch
        currentProductBatch = [];
      }
    }

    return slivers;
  }
}
