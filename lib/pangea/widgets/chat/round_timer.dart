import 'dart:async';

import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
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
  bool ongoingRound = false;
  DateTime? timerStart;

  @override
  void initState() {
    super.initState();

    timerStart = widget.controller.currentRound?.currentRoundStart;
    ongoingRound = timerStart != null;
    if (!ongoingRound) {
      timerStart = widget.controller.currentRound?.previousRoundEnd;
    }
    if (timerStart != null) {
      final roundDuration = DateTime.now().difference(timerStart!).inSeconds;
      if (roundDuration >
          (ongoingRound
              ? GameConstants.roundLength
              : GameConstants.betweenRoundLength)) return;

      currentSeconds = roundDuration;
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        currentSeconds++;
        if (currentSeconds >=
            (ongoingRound
                ? GameConstants.roundLength
                : GameConstants.betweenRoundLength)) {
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
    final endTime = gameState.previousRoundEndTime;

    if (startTime == null && endTime == null) return;
    timer?.cancel();
    timer = null;

    // if this update is the start of a round
    if (startTime != null) {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        currentSeconds++;
        if (currentSeconds >=
            (ongoingRound
                ? GameConstants.roundLength
                : GameConstants.betweenRoundLength)) {
          t.cancel();
        }
        setState(() {});
      });
      return;
    }

    // if this update is the end of a round
    currentSeconds = 0;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();

    stateSubscription?.cancel();
    stateSubscription = null;

    timer?.cancel();
    timer = null;
  }

  int get remainingTime =>
      (ongoingRound
          ? GameConstants.roundLength
          : GameConstants.betweenRoundLength) -
      currentSeconds;

  String get timerText =>
      '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    double percent = currentSeconds /
        (ongoingRound
            ? GameConstants.roundLength
            : GameConstants.betweenRoundLength);
    if (percent > 1) percent = 1;
    return CircularPercentIndicator(
      radius: 40.0,
      percent: percent,
      backgroundColor: (ongoingRound
              ? GameConstants.roundColor
              : GameConstants.betweenRoundColor)
          .withOpacity(0.5),
      progressColor: ongoingRound
          ? GameConstants.roundColor
          : GameConstants.betweenRoundColor,
      animation: true,
      animateFromLastPercent: true,
      center: Text(timerText),
    );
  }
}
