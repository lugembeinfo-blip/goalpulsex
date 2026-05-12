class NewsModel {
  final String title;
  final String image;
  final String description;
  final String date;

  NewsModel({
    required this.title,
    required this.image,
    required this.description,
    required this.date,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? "No title",
      image: json['image'] ?? "",
      description: json['description'] ?? "",
      date: json['date'] ?? "",
    );
  }
}
