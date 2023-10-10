class Video {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int duration;
  final String quality;
  final String url;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.duration,
    required this.quality,
    required this.url,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'],
      quality: json['quality'],
      url: json['url'],
    );
  }
}
