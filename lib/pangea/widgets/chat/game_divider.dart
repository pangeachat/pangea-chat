import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/widgets/chat/round_timer.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class GameDivider extends StatelessWidget {
  ChatController controller;
  final Event event;

  GameDivider(this.controller, this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    final currentCharacter =
        controller.currentRound?.gameState.currentCharacter;
    // if (currentCharacter == null) {
    //   return const SizedBox();
    // }
    final startTime = controller.currentRound?.gameState.currentRoundStartTime;

    final textColor = Theme.of(context).colorScheme.onSurface;
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppConfig.borderRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // TODO: use L10n instead of hardcoding this
                currentCharacter == null
                    ? "No character, sorry"
                    : "$currentCharacter says...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20 * AppConfig.fontSizeFactor,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              // if (startTime != null)
              RoundTimer(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
