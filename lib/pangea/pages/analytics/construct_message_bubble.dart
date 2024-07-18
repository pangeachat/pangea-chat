import 'package:fluffychat/config/app_config.dart';
import 'package:flutter/material.dart';

class ConstructMessageBubble extends StatelessWidget {
  final String errorText;
  final String replacementText;
  final int start;
  final int end;

  const ConstructMessageBubble({
    super.key,
    required this.errorText,
    required this.replacementText,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: AppConfig.messageFontSize * AppConfig.fontSizeFactor,
      height: 1.3,
    );

    return IntrinsicWidth(
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(AppConfig.borderRadius),
            bottomLeft: Radius.circular(AppConfig.borderRadius),
            bottomRight: Radius.circular(AppConfig.borderRadius),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppConfig.borderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: RichText(
            text: (end == null)
                ? TextSpan(
                    text: errorText,
                    style: defaultStyle,
                  )
                : TextSpan(
                    children: [
                      TextSpan(
                        text: errorText.substring(0, start),
                        style: defaultStyle,
                      ),
                      TextSpan(
                        text: errorText.substring(start, end),
                        style: defaultStyle.merge(
                          TextStyle(
                            backgroundColor: Colors.red.withOpacity(0.25),
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2.5,
                          ),
                        ),
                      ),
                      const TextSpan(text: " "),
                      TextSpan(
                        text: replacementText,
                        style: defaultStyle.merge(
                          TextStyle(
                            backgroundColor: Colors.green.withOpacity(0.25),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: errorText.substring(end),
                        style: defaultStyle,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
