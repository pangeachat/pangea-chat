import 'package:fluffychat/pangea/constants/analytics_constants.dart';

enum ConstructTypeEnum {
  grammar,
  vocab,
  morph,
  storySelection,
}

extension ConstructExtension on ConstructTypeEnum {
  String get string {
    switch (this) {
      case ConstructTypeEnum.grammar:
        return 'grammar';
      case ConstructTypeEnum.vocab:
        return 'vocab';
      case ConstructTypeEnum.morph:
        return 'morph';
      case ConstructTypeEnum.storySelection:
        return 'storySelection';
    }
  }

  int get maxXPPerLemma {
    switch (this) {
      case ConstructTypeEnum.vocab:
        return AnalyticsConstants.vocabUseMaxXP;
      case ConstructTypeEnum.morph:
        return AnalyticsConstants.morphUseMaxXP;
      default:
        return 0;
    }
  }
}

class ConstructTypeUtil {
  static ConstructTypeEnum fromString(String? string) {
    switch (string) {
      case 'g':
      case 'grammar':
        return ConstructTypeEnum.grammar;
      case 'v':
      case 'vocab':
        return ConstructTypeEnum.vocab;
      case 'm':
      case 'morph':
        return ConstructTypeEnum.morph;
      case 's':
      case 'storySelection':
        return ConstructTypeEnum.storySelection;
      default:
        return ConstructTypeEnum.vocab;
    }
  }
}
