import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:flutter/material.dart';

class LemmaWidget extends StatelessWidget {
  final PangeaToken token;
  final VoidCallback onPressed;
  final bool isSelected;

  const LemmaWidget({
    super.key,
    required this.token,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Text(token.xpEmoji),
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
              : null,
        ),
      ),
    );
  }
}
