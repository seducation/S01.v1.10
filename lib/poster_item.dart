
class PosterItem {
  final String id;
  final String title;
  final String imageUrl;

  PosterItem({required this.id, required this.title, required this.imageUrl});

  factory PosterItem.fromMap(Map<String, dynamic> map) {
    return PosterItem(
      id: map['\$id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
    );
  }
}
