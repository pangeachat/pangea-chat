import 'dart:ui';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/constants/analytics_constants.dart';

enum LemmaCategoryEnum {
  flowers,
  greens,
  seeds,
}

extension LemmaCategoryExtension on LemmaCategoryEnum {
  Color get color {
    switch (this) {
      case LemmaCategoryEnum.flowers:
        return AppConfig.primaryColorLight;
      case LemmaCategoryEnum.greens:
        return AppConfig.success;
      case LemmaCategoryEnum.seeds:
        return AppConfig.goldLight;
    }
  }

  String get emoji {
    switch (this) {
      case LemmaCategoryEnum.flowers:
        return "🌸";
      case LemmaCategoryEnum.greens:
        return "🌱";
      case LemmaCategoryEnum.seeds:
        return "🫛";
    }
  }

  String get xpString {
    switch (this) {
      case LemmaCategoryEnum.flowers:
        return ">${AnalyticsConstants.xpForFlower}";
      case LemmaCategoryEnum.greens:
        return ">${AnalyticsConstants.xpForGreens}";
      case LemmaCategoryEnum.seeds:
        return "<${AnalyticsConstants.xpForGreens}";
    }
  }
}
