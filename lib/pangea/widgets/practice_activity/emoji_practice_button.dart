import 'package:fluffychat/pangea/enum/activity_type_enum.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:flutter/material.dart';

class EmojiPracticeButton extends StatelessWidget {
  final PangeaToken token;
  final VoidCallback onPressed;
  final bool isSelected;

  const EmojiPracticeButton({
    required this.token,
    required this.onPressed,
    this.isSelected = false,
    super.key,
  });

  bool get _shouldDoActivity => token.shouldDoActivity(
        a: ActivityTypeEnum.emoji,
        feature: null,
        tag: null,
      );

  @override
  Widget build(BuildContext context) {
    final emoji = token.getEmoji();
    return SizedBox(
      height: 40,
      width: 40,
      child: _shouldDoActivity || emoji != null
          ? Opacity(
              opacity: _shouldDoActivity ? 0.5 : 1,
              child: IconButton(
                onPressed: onPressed,
                icon: emoji == null
                    ? const Icon(Icons.add_reaction_outlined)
                    : Text(emoji),
                style: IconButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.25)
                      : null,
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
