abstract class JsonSerializable {
  Map<String, dynamic> toJson();
  factory JsonSerializable.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}

class ContentFeedback<T extends JsonSerializable> {
  final JsonSerializable content;
  final String feedback;

  ContentFeedback(this.content, this.feedback);

  toJson() {
    return {
      'content': content.toJson(),
      'feedback': feedback,
    };
  }
}
