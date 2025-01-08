class LemmaDefinitionResponse {
  final List<String> emoji;
  final String definition;

  LemmaDefinitionResponse({
    required this.emoji,
    required this.definition,
  });

  factory LemmaDefinitionResponse.fromJson(Map<String, dynamic> json) {
    return LemmaDefinitionResponse(
      emoji: (json['emoji'] as List<dynamic>).map((e) => e as String).toList(),
      definition: json['definition'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'definition': definition,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LemmaDefinitionResponse &&
          runtimeType == other.runtimeType &&
          emoji.length == other.emoji.length &&
          emoji.every((element) => other.emoji.contains(element)) &&
          definition == other.definition;

  @override
  int get hashCode =>
      emoji.fold(0, (prev, element) => prev ^ element.hashCode) ^
      definition.hashCode;
}
