import 'package:fluffychat/pangea/models/lemma.dart';
import 'package:fluffychat/pangea/repo/lemma_definition/lemma_definition_response.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';

class LemmaDefinitionRequest {
  final Lemma _lemma;
  final String partOfSpeech;
  final String lemmaLang;
  final String userL1;

  final LemmaDefinitionResponse? feedback;

  LemmaDefinitionRequest({
    required this.partOfSpeech,
    required this.lemmaLang,
    required this.userL1,
    required Lemma lemma,
    this.feedback,
  }) : _lemma = lemma;

  String get lemma {
    if (_lemma.text.isNotEmpty) {
      return _lemma.text;
    }
    ErrorHandler.logError(
      e: "Found lemma with empty text",
      data: {
        'lemma': _lemma,
        'part_of_speech': partOfSpeech,
        'lemma_lang': lemmaLang,
        'user_l1': userL1,
        'feedback': feedback,
      },
    );
    assert(_lemma.text.isNotEmpty);

    return _lemma.text;
  }

  Map<String, dynamic> toJson() {
    return {
      'lemma': lemma,
      'part_of_speech': partOfSpeech,
      'lemma_lang': lemmaLang,
      'user_l1': userL1,
      'feedback': feedback?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LemmaDefinitionRequest &&
          runtimeType == other.runtimeType &&
          lemma == other.lemma &&
          partOfSpeech == other.partOfSpeech &&
          lemmaLang == other.lemmaLang &&
          userL1 == other.userL1;

  @override
  int get hashCode =>
      lemma.hashCode ^
      partOfSpeech.hashCode ^
      lemmaLang.hashCode ^
      userL1.hashCode;
}
