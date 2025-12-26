enum FeedItemType { product, notice, suggestion, status, trending }

enum RegionScope { village, district, state, country, global }

class FeedItem {
  final String id;
  final FeedItemType type;
  final dynamic content;
  final RegionScope regionScope;
  final int priority;
  final String? regionName;

  FeedItem({
    required this.id,
    required this.type,
    required this.content,
    required this.regionScope,
    this.priority = 0,
    this.regionName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'regionScope': regionScope.name,
      'priority': priority,
      'regionName': regionName,
    };
  }
}
