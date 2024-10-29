class PostModel {
  final int userId;
  final int id;
  final String title;
  final String body;

  PostModel({required this.userId, required this.id, required this.title, required this.body});

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }

  // Optional: Override toString for better logging
  @override
  String toString() {
    return 'PostModel(userId: $userId, id: $id, title: $title, body: $body)';
  }
}