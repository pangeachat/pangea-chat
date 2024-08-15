import 'package:collection/collection.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/pangea/widgets/chat/round_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class GameDivider extends StatelessWidget {
  final ChatController controller;
  final Event event;

  const GameDivider(this.controller, this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = controller.currentRound?.gameState;
    final eventState = GameModel.fromJson(event.content);
    final bool roundOngoing = eventState.previousRoundEndTime == null;

    // Don't show if there is no current character
    if (gameState?.currentCharacter == null) {
      return const SizedBox();
    }

    final character = gameState!.currentCharacter;
    // If there is no ongoing round, get winner of previous round
    String? winner;
    if (!roundOngoing) {
      final recentBotMessage = controller.timeline!.events.firstWhereOrNull(
        (e) =>
            e.senderId == GameConstants.gameMaster &&
            e.originServerTs.isBefore(event.originServerTs),
      );
      winner = recentBotMessage?.content[ModelKey.winner]?.toString();
      if (winner == null) {
        return const SizedBox();
      }
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
                roundOngoing
                    ? character! != ModelKey.narrator
                        ? L10n.of(context)!.currentCharDialoguePrompt(
                            character,
                          )
                        : L10n.of(context)!.narrationPrompt
                    : winner == GameConstants.gameMaster
                        ? L10n.of(context)!.botWinAnnouncement
                        : L10n.of(context)!.winnerAnnouncement(
                            winner!,
                          ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20 * AppConfig.fontSizeFactor,
                ),
              ),
            ),
          ),
        ),
        if (roundOngoing) RoundTimer(controller: controller),
        const SizedBox(
          height: 9,
        ),
      ],
    );
  }
}
