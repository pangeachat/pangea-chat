import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/common/utils/error_handler.dart';
import 'package:flutter/foundation.dart';

class MorphFeature {
  final String feature;
  final List<String> tag;

  MorphFeature({required this.feature, required this.tag});

  factory MorphFeature.fromJson(Map<String, dynamic> json) {
    return MorphFeature(
      feature: json['feature'],
      tag: List<String>.from(json['tag']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': feature,
      'tag': tag,
    };
  }
}

class MorphsByLanguage {
  final String languageCode;
  final List<MorphFeature> features;

  MorphsByLanguage({required this.languageCode, required this.features});

  factory MorphsByLanguage.fromJson(Map<String, dynamic> json) {
    return MorphsByLanguage(
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

  List<String> getLabelsForMorphCategory(String feature) {
    final tags =
        features.firstWhereOrNull((element) => element.feature == feature)?.tag;

    debugger(when: tags == null && kDebugMode);

    return tags ?? [];
  }

  List<String> get categories => features.map((e) => e.feature).toList();

  String guessMorphCategory(String morphLemma) {
    for (final MorphFeature feature in features) {
      if (feature.tag.contains(morphLemma)) {
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
