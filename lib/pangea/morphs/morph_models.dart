import 'package:collection/collection.dart';

import 'package:fluffychat/pangea/common/utils/error_handler.dart';

class MorphFeature {
  final String feature;
  final List<String> tags;

  MorphFeature({required this.feature, required this.tags});

  factory MorphFeature.fromJson(Map<String, dynamic> json) {
    return MorphFeature(
      feature: json['feature'],
      tags: List<String>.from(json['tag']),
    );
  }

  List<String> get displayTags => tags
      .where(
        (t) =>
            !["punct", "space", "sym", "x", "other"].contains(t.toLowerCase()),
      )
      .toList();

  Map<String, dynamic> toJson() {
    return {
      'feature': feature,
      'tag': tags,
    };
  }
}

class MorphFeatuuresAndTags {
  final String languageCode;
  final List<MorphFeature> features;

  MorphFeatuuresAndTags({required this.languageCode, required this.features});

  factory MorphFeatuuresAndTags.fromJson(Map<String, dynamic> json) {
    return MorphFeatuuresAndTags(
      languageCode: json['language_code'],
      features: List<MorphFeature>.from(
        json['features'].map((x) => MorphFeature.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'features': features.map((x) => x.toJson()).toList(),
    };
  }

  /// Returns the tags for a given feature
  List<String> getAllTags(String feature) =>
      features
          .firstWhereOrNull((element) => element.feature == feature)
          ?.tags ??
      [];

  /// Returns the display tags for a given feature
  /// i.e. minus punc, space, x, etc
  List<String> getDisplayTags(String feature) =>
      features
          .firstWhereOrNull((element) => element.feature == feature)
          ?.displayTags ??
      [];

  List<MorphFeature> get displayFeatures => features
      .where(
        (f) => f.feature.toLowerCase() != "foreign",
      )
      .toList();

  List<String> get categories => features.map((e) => e.feature).toList();

  String guessMorphCategory(String morphLemma) {
    for (final MorphFeature feature in features) {
      if (feature.tags.contains(morphLemma)) {
        // debugPrint(
        //   "found missing construct category for $morphLemma: $category",
        // );
        return feature.feature;
      }
    }
    ErrorHandler.logError(
      m: "Morph construct lemma $morphLemma not found in morph categories and labels",
      data: {
        "morphLemma": morphLemma,
      },
    );
    return "Other";
  }
}
