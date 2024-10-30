class PostModel {
  final int userId;
  final int id;
  final String title;
  final String body;

  PostModel(
      {required this.userId,
      required this.id,
      required this.title,
      required this.body});

  //fromJson is a factory constructor, used for creating a PostModel instance from a JSON map (typically from an API response).
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
  //The toJson method converts a PostModel instance into a JSON map.
  //This method is often used to send data to an API in JSON format.
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

//Notes
//The PostModel class helps map JSON data to a Dart object and back, making it convenient to work with data from an API, store it locally, or send it back in JSON format.