import 'dart:math';
import '../models/feed_item.dart';

class FeedInjectionAlgorithm {
  final Random _random = Random();

  /// Design a feed injection algorithm for a region-aware community tab.
  ///
  /// Products are the base feed and must appear continuously.
  /// After every 10–20 product items, inject one secondary content block.
  ///
  /// Injected content types include:
  /// - Friend suggestions (horizontal list)
  /// - Local notices / notice board (auto-expire in 7 days)
  /// - Local status updates
  /// - Regional trending items
  ///
  /// Injection must be context-aware and region-aware.
  List<FeedItem> injectFeed({
    required List<FeedItem> products,
    required List<FeedItem> secondaryContent,
    required String selectedRegion,
    required RegionScope selectedScope,
  }) {
    List<FeedItem> result = [];

    // 1. Filter secondary content by region scope
    // Content must match the same region scope unless explicitly marked as global
    List<FeedItem> filteredSecondary = secondaryContent.where((item) {
      if (item.regionScope == RegionScope.global) return true;
      return item.regionName == selectedRegion &&
          item.regionScope == selectedScope;
    }).toList();

    // Sort by priority (Product has highest priority, handled by being base feed)
    filteredSecondary.sort((a, b) => b.priority.compareTo(a.priority));

    if (products.isEmpty) {
      return result;
    }

    int productIndex = 0;
    int secondaryIndex = 0;

    while (productIndex < products.length) {
      // Determine next injection point (10-20 products)
      int nextInjectionGap = 10 + _random.nextInt(11); // 10 to 20

      // Add products up to the next injection gap
      for (
        int i = 0;
        i < nextInjectionGap && productIndex < products.length;
        i++
      ) {
        result.add(products[productIndex++]);
      }

      // Inject one secondary block if available
      if (secondaryIndex < filteredSecondary.length &&
          productIndex < products.length) {
        // Skip injection and continue with products if no secondary content available
        // Behavior rules: No two injected blocks may appear back-to-back.
        // This is naturally handled by the gap logic above.

        result.add(filteredSecondary[secondaryIndex++]);
      }
    }

    return result;
  }
}
