import 'package:collection/collection.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/widgets/animations/progress_bar/progress_bar.dart';
import 'package:fluffychat/pangea/widgets/animations/progress_bar/progress_bar_details.dart';
import 'package:fluffychat/utils/string_color.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class GameLeaderBoard extends StatelessWidget {
  final Room room;
  final double width;
  const GameLeaderBoard({
    super.key,
    required this.room,
    this.width = FluffyThemes.columnWidth,
  });

  List<MapEntry<String, int>>? get currentScoreEntries =>
      room.gameState.score?.entries.toList();

  Color userColor(String userId, User? user) {
    final displayName = user?.calcDisplayname() ?? userId.localpart ?? userId;
    return displayName.lightColorAvatar;
  }

  Widget userProgressBar(BuildContext context, int index) {
    final points = currentScoreEntries![index].value;
    final userId = currentScoreEntries![index].key;
    final user = room.getParticipants().firstWhereOrNull((e) => e.id == userId);
    final color = userColor(userId, user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.calcDisplayname() ?? userId.localpart ?? userId,
              style: TextStyle(color: color, fontSize: 12),
            ),
            ProgressBar(
              levelBars: [
                LevelBarDetails(
                  fillColor: color,
                  currentPoints: points,
                ),
              ],
              progressBarDetails: ProgressBarDetails(
                pointsPerLevel: 20,
                totalWidth: width * 0.8,
                borderColor: color.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: currentScoreEntries?.length ?? 0,
      itemBuilder: userProgressBar,
    );
  }
}
