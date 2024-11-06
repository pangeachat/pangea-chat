import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:flutter/material.dart';

class BotStyle {
  static TextStyle text(
    BuildContext context, {
    TextStyle? existingStyle,
    bool setColor = true,
    bool big = false,
    bool italics = false,
    bool bold = false,
  }) {
    try {
      final TextStyle botStyle = TextStyle(
        fontWeight: bold ? FontWeight.w700 : null,
        fontSize: AppConfig.messageFontSize *
            AppConfig.fontSizeFactor *
            (big == true ? 1.2 : 1),
        fontStyle: italics ? FontStyle.italic : null,
        color: setColor ? Theme.of(context).colorScheme.primary : null,
        inherit: true,
      );

      return existingStyle?.merge(botStyle) ?? botStyle;
    } catch (err, stack) {
      ErrorHandler.logError(m: "error getting styles", s: stack);
      return existingStyle ?? const TextStyle();
    }
  }
}
