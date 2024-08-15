import 'package:collection/collection.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
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
    final gameState = controller.room.gameState;
    final eventState = GameModel.fromJson(event.content);

    // Don't show if there is no current character
    if (gameState.currentCharacter == null ||
        eventState.currentRoundStartTime == null) {
      return const SizedBox();
    }

    // If there is no ongoing round, get winner of previous round
    String? winner;
    if (!controller.room.isActiveRound) {
      final recentBotMessage = controller.timeline!.events.firstWhereOrNull(
        (e) =>
            e.senderId == GameConstants.gameMaster &&
            e.originServerTs.isBefore(event.originServerTs),
      );
      winner = recentBotMessage?.content[ModelKey.winner]?.toString();
      // ignore: prefer_conditional_assignment
      if (winner == null) {
        // return const SizedBox();
        winner = "?";
      }
    }

    final character = gameState.currentCharacter;
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
                controller.room.isActiveRound
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
        if (controller.room.isActiveRound) RoundTimer(controller: controller),
        const SizedBox(
          height: 9,
        ),
      ],
    );
  }
}

// TODO delete this - just for testing
class StartRoundButton extends StatelessWidget {
  final ChatController controller;

  const StartRoundButton(this.controller, {super.key});

  void startRound() {
    debugPrint("starting round");
    final gameState = controller.room.gameState;
    gameState.currentRoundStartTime = DateTime.now();
    gameState.currentCharacter = "Sally May";
    controller.room.client.setRoomStateWithKey(
      controller.roomId,
      PangeaEventTypes.storyGame,
      '',
      gameState.toJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: startRound,
      ),
    );
  }
}
