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
