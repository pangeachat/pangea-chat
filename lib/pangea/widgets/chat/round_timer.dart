import 'dart:async';

import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Create a timer that counts down to the given time
/// Default duration is 180 seconds
class RoundTimer extends StatefulWidget {
  final ChatController controller;
  const RoundTimer({
    super.key,
    required this.controller,
  });

  @override
  RoundTimerState createState() => RoundTimerState();
}

class RoundTimerState extends State<RoundTimer> {
  int currentSeconds = 0;
  Timer? timer;
  StreamSubscription? stateSubscription;

  @override
  void initState() {
    super.initState();

    final roundStartTime =
        widget.controller.room.gameState.currentRoundStartTime;
    if (roundStartTime != null) {
      final roundDuration = DateTime.now().difference(roundStartTime).inSeconds;
      if (roundDuration > GameConstants.timerMaxSeconds) return;

      currentSeconds = roundDuration;
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        currentSeconds++;
        if (currentSeconds >= GameConstants.timerMaxSeconds) {
          t.cancel();
        }
        setState(() {});
      });
    }

    stateSubscription = Matrix.of(context)
        .client
        .onRoomState
        .stream
        .where(isRoundUpdate)
        .listen(onRoundUpdate);
  }

  bool isRoundUpdate(update) {
    return update.roomId == widget.controller.room.id &&
        update.state is Event &&
        (update.state as Event).type == PangeaEventTypes.storyGame;
  }

  void onRoundUpdate(update) {
    final GameModel gameState = GameModel.fromJson(
      (update.state as Event).content,
    );
    debugPrint("game state update: ${gameState.toJson()}");
    final startTime = gameState.currentRoundStartTime;

    if (startTime == null) return;
    timer?.cancel();

    if (!widget.controller.room.isActiveRound) {
      currentSeconds = 0;
      setState(() {});
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      currentSeconds++;
      if (currentSeconds >= GameConstants.timerMaxSeconds) {
        t.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    stateSubscription?.cancel();
    stateSubscription = null;

    timer?.cancel();
    timer = null;
  }

  int get remainingTime => GameConstants.timerMaxSeconds - currentSeconds;

  String get timerText =>
      '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    double percent = currentSeconds / GameConstants.timerMaxSeconds;
    if (percent > 1) percent = 1;
    return CircularPercentIndicator(
      radius: 40.0,
      percent: percent,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
      progressColor: Theme.of(context).colorScheme.primary,
      animation: true,
      animateFromLastPercent: true,
      center: Text(timerText),
    );
  }
}
