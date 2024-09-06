import 'dart:async';

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/pangea/utils/bot_style.dart';
import 'package:fluffychat/pangea/widgets/chat/round_timer.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class GameStateView extends StatefulWidget {
  final Room room;
  const GameStateView(this.room, {super.key});

  @override
  GameStateViewState createState() => GameStateViewState();
}

class GameStateViewState extends State<GameStateView> {
  final int roundDelaySeconds = 5;
  Timer? timer;
  StreamSubscription? stateSubscription;

  GameModel get gameState => room.gameState;
  Room get room => widget.room;

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

  bool isRoundUpdate(update) {
    return update.roomId == room.id &&
        update.state is Event &&
        (update.state as Event).type == PangeaEventTypes.storyGame;
  }

  void onGameStateUpdate({bool animate = true}) {
    setState(() {});
    if (gameState.timerEnds != null) {
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (gameState.timerEnds == null ||
            gameState.timerEnds!.isBefore(DateTime.now())) {
          t.cancel();
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    stateSubscription?.cancel();
    stateSubscription = null;

    timer?.cancel();
    timer = null;
  }

  String? get avatarName =>
      room.isActiveRound && gameState.playerCharacter != ModelKey.narrator
          ? gameState.playerCharacter
          : null;

  // User? get judge => room.getParticipants().firstWhereOrNull(
  //       (user) => user.id == gameState.judge,
  //     );

  List<User> get players => room
      .getParticipants()
      .where(
        (user) => user.id != BotName.byEnvironment,
        // && user.id != gameState.judge,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    if (gameState.timerText == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    AnimatedSize(
                      duration: FluffyThemes.animationDuration,
                      child: avatarName == null
                          ? const SizedBox.shrink()
                          : Avatar(name: avatarName),
                    ),
                    const SizedBox(width: 8),
                    gameState.timerText != null
                        ? Text(
                            gameState.timerText!,
                            textAlign: TextAlign.center,
                            style: BotStyle.text(context, big: true),
                          )
                        : const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                  ],
                ),
              ),
              gameState.timerEnds == null || gameState.timerStarts == null
                  ? const SizedBox(width: 84)
                  : RoundTimer(
                      // currentSeconds ?? 0,
                      // maxSeconds: room.isBetweenRounds
                      //     ? gameState.delayBeforeNextRoundSeconds
                      //     : GameConstants.timerMaxSeconds,
                      timerStarts: gameState.timerStarts!,
                      timerEnds: gameState.timerEnds!,
                      // color: room.isBetweenRounds ? Colors.green : null,
                    ),
            ],
          ),
          if (room.isActiveRound &&
              // gameState.judge != null &&
              players.isNotEmpty)
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Text(
            //       L10n.of(context)!.judgeThisRound,
            //       style: BotStyle.text(context),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(2),
            //       child: Tooltip(
            //         message: judge?.calcDisplayname() ?? gameState.judge,
            //         child: Avatar(
            //           mxContent: judge?.avatarUrl,
            //           name: judge?.calcDisplayname() ?? gameState.judge,
            //           size: 24,
            //           onTap: () {},
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Text(
            //       L10n.of(context)!.playersThisRound,
            //       style: BotStyle.text(context),
            //     ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: players.map((user) {
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: Tooltip(
                    message: user.calcDisplayname(),
                    child: AnimatedOpacity(
                      duration: FluffyThemes.animationDuration,
                      opacity: room.userHasVotedThisRound(user.id) ? 1 : 0.25,
                      child: Avatar(
                        mxContent: user.avatarUrl,
                        name: user.calcDisplayname(),
                        size: 24,
                        onTap: () {},
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          //       ],
          //     ),
          // ],
        ],
      ),
    );
  }
}
