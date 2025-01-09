import 'package:fluffychat/pangea/models/content_feedback.dart';
import 'package:fluffychat/pangea/repo/lemma_info/lemma_info_response.dart';

class LemmaInfoRequest {
  final String lemma;
  final String partOfSpeech;
  final String lemmaLang;
  final String userL1;

  ContentFeedback<LemmaInfoResponse>? feedback;

  LemmaInfoRequest({
    required this.partOfSpeech,
    required this.lemmaLang,
    required this.userL1,
    required this.lemma,
    this.feedback,
  });

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
      other is LemmaInfoRequest &&
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
