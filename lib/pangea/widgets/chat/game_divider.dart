import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/pangea/utils/bot_style.dart';
import 'package:fluffychat/pangea/widgets/chat/round_timer.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class GameDivider extends StatefulWidget {
  final ChatController controller;
  final Event event;

  const GameDivider(this.controller, this.event, {super.key});

  @override
  GameDividerState createState() => GameDividerState();
}

class GameDividerState extends State<GameDivider> {
  Timer? timer;
  StreamSubscription? stateSubscription;
  bool _animate = false;

  get gameState => widget.controller.room.gameState;
  get eventState => GameModel.fromJson(widget.event.content);
  int get currentSeconds => widget.controller.room.isActiveRound
      ? (widget.controller.room.currentRoundDuration?.inSeconds ?? 0)
      : 0;

  @override
  void initState() {
    super.initState();

    setTimer(animate: false);

    stateSubscription = Matrix.of(context)
        .client
        .onRoomState
        .stream
        .where(isRoundUpdate)
        .listen((_) => setTimer());
  }

  void setTimer({bool animate = true}) {
    if (animate) {
      setState(() {
        _animate = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _animate = false);
        });
      });
    }

    if (!widget.controller.room.isActiveRound) return;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (currentSeconds >= GameConstants.timerMaxSeconds) {
        t.cancel();
      }
      setState(() {});
    });
  }

  bool isRoundUpdate(update) {
    return update.roomId == widget.controller.room.id &&
        update.state is Event &&
        (update.state as Event).type == PangeaEventTypes.storyGame;
  }

  @override
  void dispose() {
    super.dispose();

    stateSubscription?.cancel();
    stateSubscription = null;

    timer?.cancel();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if there is no current character
    if (gameState.currentCharacter == null ||
        eventState.currentRoundStartTime == null) {
      return const SizedBox();
    }

    // If there is no ongoing round, get winner of previous round
    String? winner;
    if (!widget.controller.room.isActiveRound) {
      final recentBotMessage =
          widget.controller.timeline!.events.firstWhereOrNull(
        (e) =>
            e.senderId == GameConstants.gameMaster &&
            e.originServerTs.isAfter(
              gameState.currentRoundStartTime!,
            ),
      );
      winner = recentBotMessage?.content[ModelKey.winner]?.toString();
    }

    final character = gameState.currentCharacter;
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    final bool isActiveRound = widget.controller.room.isActiveRound;
    final bool isCalculatingWinner = !isActiveRound && winner == null;

    String? blockText;
    String? avatarName;
    if (isActiveRound) {
      blockText = character! != ModelKey.narrator
          ? L10n.of(context)!.currentCharDialoguePrompt(character)
          : L10n.of(context)!.narrationPrompt;
      avatarName = character;
    } else if (isCalculatingWinner) {
      blockText = L10n.of(context)!.calculatingWinner;
    } else {
      if (winner == GameConstants.gameMaster) {
        blockText = L10n.of(context)!.botWinAnnouncement;
      } else {
        final winnerDisplayName = widget.controller.room
                .getParticipants()
                .firstWhereOrNull(
                  (u) => u.id == winner,
                )
                ?.calcDisplayname() ??
            winner!.localpart;
        blockText = L10n.of(context)!.winnerAnnouncement(winnerDisplayName!);
        avatarName = winnerDisplayName;
      }
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: FluffyThemes.columnWidth * 1.25,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: AnimatedSize(
          duration: FluffyThemes.animationDuration,
          curve: FluffyThemes.animationCurve,
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          child: _animate
              ? const SizedBox(height: 0, width: double.infinity)
              : Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSize(
                              duration: FluffyThemes.animationDuration,
                              child: avatarName == null
                                  ? const SizedBox.shrink()
                                  : Avatar(name: avatarName),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              blockText,
                              textAlign: TextAlign.center,
                              style: BotStyle.text(context, big: true),
                            ),
                          ],
                        ),
                      ),
                      RoundTimer(currentSeconds),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// // TODO delete this - just for testing
// class StartRoundButton extends StatelessWidget {
//   final ChatController controller;

//   const StartRoundButton(this.controller, {super.key});

//   void startRound() {
//     final gameState = controller.room.gameState;
//     debugPrint("gameState: ${gameState.toJson()}");
//     gameState.currentRoundStartTime = DateTime.now();
//     gameState.currentCharacter = "Sally May";
//     controller.room.client.setRoomStateWithKey(
//       controller.roomId,
//       PangeaEventTypes.storyGame,
//       '',
//       gameState.toJson(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: IconButton(
//         icon: const Icon(Icons.play_arrow),
//         onPressed: startRound,
//       ),
//     );
//   }
// }

// // TODO delete this - just for testing
// class SendWinnerButton extends StatelessWidget {
//   final ChatController controller;

//   const SendWinnerButton(this.controller, {super.key});

//   void sendWinner() {
//     controller.room.sendEvent({
//       ModelKey.character: "Sally May",
//       // ModelKey.character: ModelKey.narrator,
//       ModelKey.winner: "@test_7_30_1:staging.pangea.chat",
//       "body": "Here's the winning message",
//       // "body": "Here's a message from the narrator",
//       "msgtype": "m.text",
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: IconButton(
//         icon: const Icon(Icons.message),
//         onPressed: sendWinner,
//       ),
//     );
//   }
// }
