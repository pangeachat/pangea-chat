import 'package:fluffychat/pangea/models/content_feedback.dart';

class LemmaInfoResponse implements JsonSerializable {
  final List<String> emoji;
  final String definition;

  LemmaInfoResponse({
    required this.emoji,
    required this.definition,
  });

  factory LemmaInfoResponse.fromJson(Map<String, dynamic> json) {
    return LemmaInfoResponse(
      emoji: (json['emoji'] as List<dynamic>).map((e) => e as String).toList(),
      definition: json['definition'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'definition': definition,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LemmaInfoResponse &&
          runtimeType == other.runtimeType &&
          emoji.length == other.emoji.length &&
          emoji.every((element) => other.emoji.contains(element)) &&
          definition == other.definition;

  @override
  int get hashCode =>
      emoji.fold(0, (prev, element) => prev ^ element.hashCode) ^
      definition.hashCode;
}
