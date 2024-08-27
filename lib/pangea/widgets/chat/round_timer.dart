import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Create a timer that counts down to the given time
/// Default duration is 180 seconds
class RoundTimer extends StatelessWidget {
  final int currentSeconds;
  final int maxSeconds;
  final Color? color;

  const RoundTimer(
    this.currentSeconds, {
    this.maxSeconds = GameConstants.timerMaxSeconds,
    this.color,
    super.key,
  });

  int get remainingTime => maxSeconds - currentSeconds;

  String get timerText =>
      '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;
    double percent = currentSeconds / maxSeconds;
    if (percent > 1) percent = 1;
    if (percent < 0) percent = 0;
    return CircularPercentIndicator(
      radius: 40.0,
      percent: percent,
      backgroundColor: color.withOpacity(0.5),
      progressColor: color,
      animation: true,
      animateFromLastPercent: true,
      center: Text(timerText),
      animateToInitialPercent: false,
    );
  }
}
