import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Create a timer that counts down to the given time
/// Default duration is 180 seconds
class RoundTimer extends StatelessWidget {
  final int currentSeconds;
  final int maxSeconds;

  const RoundTimer(
    this.currentSeconds, {
    this.maxSeconds = GameConstants.timerMaxSeconds,
    super.key,
  });

  int get remainingTime => maxSeconds - currentSeconds;

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
      animateToInitialPercent: false,
    );
  }
}
