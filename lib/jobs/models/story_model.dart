

class StoryItemModel {
  final String imageUrl;
  final String title;
  final String description;
  final Duration duration;
  StoryItemModel({
    required this.imageUrl,
    required this.title,
    required this.description,
    this.duration = const Duration(seconds: 5),
  });
}