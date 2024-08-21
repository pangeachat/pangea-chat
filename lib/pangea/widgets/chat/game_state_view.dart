import 'dart:async';

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

class GameStateView extends StatefulWidget {
  final ChatController controller;

  const GameStateView(this.controller, {super.key});

  @override
  GameStateViewState createState() => GameStateViewState();
}

class GameStateViewState extends State<GameStateView> {
  Timer? timer;
  StreamSubscription? stateSubscription;
  // DateTime? waitBeginTime;

  GameModel get gameState => widget.controller.room.gameState;
  int get currentSeconds {
    if (widget.controller.room.isActiveRound) {
      return widget.controller.room.currentRoundDuration?.inSeconds ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();

    onGameStateUpdate(animate: false);

    stateSubscription = Matrix.of(context)
        .client
        .onRoomState
        .stream
        .where(isRoundUpdate)
        .listen((_) => onGameStateUpdate());
  }

  void onGameStateUpdate({bool animate = true}) {
    setState(() {});
    // if (gameState.phase == StoryGamePhase.beginWaitNextRound) {
    //   debugPrint("BEGIN ROUND WAIT");
    //   waitBeginTime = DateTime.now();
    // }
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
        gameState.currentRoundStartTime == null) {
      return const SizedBox();
    }

    final character = gameState.currentCharacter;
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    final bool isActiveRound = widget.controller.room.isActiveRound;

    String? blockText;
    String? avatarName;
    if (isActiveRound) {
      blockText = character! != ModelKey.narrator
          ? L10n.of(context)!.currentCharDialoguePrompt(character)
          : L10n.of(context)!.narrationPrompt;
      avatarName = character;
    } else if (!widget.controller.room.isBetweenRounds) {
      blockText = L10n.of(context)!.choosingPath;
    } else {
      blockText = L10n.of(context)!.waitingForNextRound;
    }

    return Container(
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
              mainAxisSize: MainAxisSize.min,
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
    );
  }
}

// TODO delete this - just for testing
class StartRoundButton extends StatelessWidget {
  final ChatController controller;

  const StartRoundButton(this.controller, {super.key});

  void startRound() {
    final gameState = controller.room.gameState;
    debugPrint("gameState: ${gameState.toJson()}");
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
