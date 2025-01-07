import 'package:fluffychat/pangea/enum/analytics/analytics_summary_enum.dart';

class AnalyticsSummaryModel {
  String username;
  int level;
  int totalXP;

  int numLemmas;
  List<String> listLemmas;
  int numLemmasUsedCorrectly;
  List<String> listLemmasUsedCorrectly;
  int numLemmasUsedIncorrectly;
  List<String> listLemmasUsedIncorrectly;

  /// 0 - 30 XP
  int numLemmasSmallXP;
  List<String> listLemmasSmallXP;

  /// 31 - 200 XP
  int numLemmasMediumXP;
  List<String> listLemmasMediumXP;

  /// > 200 XP
  int numLemmasLargeXP;
  List<String> listLemmasLargeXP;
  int numMorphConstructs;
  List<String> listMorphConstructs;
  List<String> listMorphConstructsUsedCorrectly;
  List<String> listMorphConstructsUsedIncorrectly;
  List<ConstructUseCase> incorrectMorphConstructUseCases;

  // list morph 0 - 30 XP
  List<String> listMorphSmallXP;

  // list morph 31 - 200 XP
  List<String> listMorphMediumXP;

  // list morph 200 - 500 XP
  List<String> listMorphLargeXP;

  // list morph > 500 XP
  List<String> listMorphHugeXP;

  int numMessagesSent;
  int numWordsTyped;
  int numChoicesCorrect;
  int numChoicesIncorrect;

  AnalyticsSummaryModel({
    required this.username,
    required this.level,
    required this.totalXP,
    required this.numLemmas,
    required this.listLemmas,
    required this.numLemmasUsedCorrectly,
    required this.listLemmasUsedCorrectly,
    required this.numLemmasUsedIncorrectly,
    required this.listLemmasUsedIncorrectly,
    required this.numLemmasSmallXP,
    required this.listLemmasSmallXP,
    required this.numLemmasMediumXP,
    required this.listLemmasMediumXP,
    required this.numLemmasLargeXP,
    required this.listLemmasLargeXP,
    required this.numMorphConstructs,
    required this.listMorphConstructs,
    required this.listMorphConstructsUsedCorrectly,
    required this.listMorphConstructsUsedIncorrectly,
    required this.incorrectMorphConstructUseCases,
    required this.listMorphSmallXP,
    required this.listMorphMediumXP,
    required this.listMorphLargeXP,
    required this.listMorphHugeXP,
    required this.numMessagesSent,
    required this.numWordsTyped,
    required this.numChoicesCorrect,
    required this.numChoicesIncorrect,
  });

  dynamic getValue(AnalyticsSummaryEnum key) {
    switch (key) {
      case AnalyticsSummaryEnum.username:
        return username;
      case AnalyticsSummaryEnum.level:
        return level;
      case AnalyticsSummaryEnum.totalXP:
        return totalXP;
      case AnalyticsSummaryEnum.numLemmas:
        return numLemmas;
      case AnalyticsSummaryEnum.listLemmas:
        return listLemmas;
      case AnalyticsSummaryEnum.numLemmasUsedCorrectly:
        return numLemmasUsedCorrectly;
      case AnalyticsSummaryEnum.listLemmasUsedCorrectly:
        return listLemmasUsedCorrectly;
      case AnalyticsSummaryEnum.numLemmasUsedIncorrectly:
        return numLemmasUsedIncorrectly;
      case AnalyticsSummaryEnum.listLemmasUsedIncorrectly:
        return listLemmasUsedIncorrectly;
      case AnalyticsSummaryEnum.numLemmasSmallXP:
        return numLemmasSmallXP;
      case AnalyticsSummaryEnum.listLemmasSmallXP:
        return listLemmasSmallXP;
      case AnalyticsSummaryEnum.numLemmasMediumXP:
        return numLemmasMediumXP;
      case AnalyticsSummaryEnum.listLemmasMediumXP:
        return listLemmasMediumXP;
      case AnalyticsSummaryEnum.numLemmasLargeXP:
        return numLemmasLargeXP;
      case AnalyticsSummaryEnum.listLemmasLargeXP:
        return listLemmasLargeXP;
      case AnalyticsSummaryEnum.numMorphConstructs:
        return numMorphConstructs;
      case AnalyticsSummaryEnum.listMorphConstructs:
        return listMorphConstructs;
      case AnalyticsSummaryEnum.listMorphConstructsUsedCorrectly:
        return listMorphConstructsUsedCorrectly;
      case AnalyticsSummaryEnum.listMorphConstructsUsedIncorrectly:
        return listMorphConstructsUsedIncorrectly;
      case AnalyticsSummaryEnum.incorrectMorphConstructUseCases:
        return incorrectMorphConstructUseCases;
      case AnalyticsSummaryEnum.listMorphSmallXP:
        return listMorphSmallXP;
      case AnalyticsSummaryEnum.listMorphMediumXP:
        return listMorphMediumXP;
      case AnalyticsSummaryEnum.listMorphLargeXP:
        return listMorphLargeXP;
      case AnalyticsSummaryEnum.listMorphHugeXP:
        return listMorphHugeXP;
      case AnalyticsSummaryEnum.numMessagesSent:
        return numMessagesSent;
      case AnalyticsSummaryEnum.numWordsTyped:
        return numWordsTyped;
      case AnalyticsSummaryEnum.numChoicesCorrect:
        return numChoicesCorrect;
      case AnalyticsSummaryEnum.numChoicesIncorrect:
        return numChoicesIncorrect;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'level': level,
      'totalXP': totalXP,
      'numLemmas': numLemmas,
      'listLemmas': listLemmas,
      'numLemmasUsedCorrectly': numLemmasUsedCorrectly,
      'listLemmasUsedCorrectly': listLemmasUsedCorrectly,
      'numLemmasUsedIncorrectly': numLemmasUsedIncorrectly,
      'listLemmasUsedIncorrectly': listLemmasUsedIncorrectly,
      'numLemmasSmallXP': numLemmasSmallXP,
      'listLemmasSmallXP': listLemmasSmallXP,
      'numLemmasMediumXP': numLemmasMediumXP,
      'listLemmasMediumXP': listLemmasMediumXP,
      'numLemmasLargeXP': numLemmasLargeXP,
      'listLemmasLargeXP': listLemmasLargeXP,
      'numMorphConstructs': numMorphConstructs,
      'listMorphConstructs': listMorphConstructs,
      'listMorphConstructsUsedCorrectly': listMorphConstructsUsedCorrectly,
      'listMorphConstructsUsedIncorrectly': listMorphConstructsUsedIncorrectly,
      'incorrectMorphConstructUseCases': incorrectMorphConstructUseCases,
      'listMorphSmallXP': listMorphSmallXP,
      'listMorphMediumXP': listMorphMediumXP,
      'listMorphLargeXP': listMorphLargeXP,
      'listMorphHugeXP': listMorphHugeXP,
      'numMessagesSent': numMessagesSent,
      'numWordsWithoutAssistance': numWordsTyped,
      'numChoicesCorrect': numChoicesCorrect,
      'numChoicesIncorrect': numChoicesIncorrect,
    };
  }
}

class ConstructUseCase {}
