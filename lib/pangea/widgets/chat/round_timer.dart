import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

/// Create a timer that counts down to the given time
/// Default duration is 180 seconds
class RoundTimer extends StatelessWidget {
  final DateTime timerEnds;
  final DateTime timerStarts;
  final Color? color;

  const RoundTimer({
    required this.timerEnds,
    required this.timerStarts,
    this.color,
    super.key,
  });

  int get remainingTime {
    return timerEnds.difference(DateTime.now()).inSeconds;
  }

  int get currentTime {
    return DateTime.now().difference(timerStarts).inSeconds;
  }

  String get timerText =>
      '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Theme.of(context).colorScheme.primary;
    final totalTime = timerEnds.difference(timerStarts).inSeconds;
    double percent = currentTime / totalTime;
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
