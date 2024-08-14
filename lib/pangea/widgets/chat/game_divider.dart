import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/pangea/widgets/chat/round_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class GameDivider extends StatelessWidget {
  ChatController controller;
  final Event event;

  GameDivider(this.controller, this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = controller.currentRound?.gameState;
    final eventState = GameModel.fromJson(event.content);
    // Only show most recent divider
    // Check that event time == current round start/end time
    if ((eventState.previousRoundEndTime == null)
        ? (eventState.currentRoundStartTime != gameState?.currentRoundStartTime)
        : (eventState.previousRoundEndTime !=
            gameState?.previousRoundEndTime)) {
      return const SizedBox();
    }
    // Don't show if there is no current character
    if (gameState?.currentCharacter == null) {
      return const SizedBox();
    }

    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
              child: Text(
                // TODO: use L10n instead of hardcoding this
                L10n.of(context)!.currentCharDialoguePrompt(
                  gameState!.currentCharacter!,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20 * AppConfig.fontSizeFactor,
                ),
              ),
            ),
          ),
        ),
        // if (startTime != null)
        RoundTimer(controller: controller),
        const SizedBox(
          height: 9,
        ),
      ],
    );
  }
}
