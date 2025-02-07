import 'package:fluffychat/pangea/events/models/content_feedback.dart';

class MorphInfoResponse implements JsonSerializable {
  final String meaning;

  MorphInfoResponse({
    required this.meaning,
  });

  factory MorphInfoResponse.fromJson(Map<String, dynamic> json) {
    return MorphInfoResponse(
      meaning: json['meaning'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'meaning': meaning,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphInfoResponse &&
          runtimeType == other.runtimeType &&
          meaning == other.meaning;

  @override
  int get hashCode => meaning.hashCode;
}
