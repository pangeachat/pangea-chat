import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/pangea/widgets/animations/progress_bar/progress_bar.dart';
import 'package:fluffychat/pangea/widgets/animations/progress_bar/progress_bar_details.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class GameLeaderBoard extends StatefulWidget {
  final Room room;
  final double width;
  const GameLeaderBoard({
    super.key,
    required this.room,
    this.width = FluffyThemes.columnWidth,
  });

  @override
  GameLeaderBoardState createState() => GameLeaderBoardState();
}

class GameLeaderBoardState extends State<GameLeaderBoard> {
  Map<String, int>? get currentScore => widget.room.gameState.score;
  List<User> get users => widget.room
      .getParticipants()
      .where((user) => user.id != BotName.byEnvironment)
      .toList();
  bool _loading = false;

  void loadMoreUsers() {
    if (_loading) return;
    setState(() => _loading = true);
    widget.room.requestParticipants().then((_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tiles = users
        .map(
          (user) => UserProgressBar(
            room: widget.room,
            points: currentScore?[user.id] ?? 0,
            user: user,
            width: widget.width,
          ),
        )
        .cast<Widget>()
        .toList();

    if (!widget.room.participantListComplete) {
      tiles.add(
        TextButton(
          onPressed: () => widget.room.requestParticipants().then((_) {
            if (mounted) setState(() {});
          }),
          child: _loading
              ? const CircularProgressIndicator.adaptive()
              : Text(L10n.of(context)!.loadMore),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(children: tiles),
    );
  }
}

class UserProgressBar extends StatelessWidget {
  final Room room;
  final User user;
  final int points;
  final double width;

  const UserProgressBar({
    super.key,
    required this.user,
    required this.points,
    required this.room,
    this.width = FluffyThemes.columnWidth,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.calcDisplayname();

    return ListTile(
      onTap: () {},
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
          ),
          Avatar(
            name: displayName,
            mxContent: user.avatarUrl,
            size: 40,
          ),
        ],
      ),
      title: Text(
        user.calcDisplayname(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
      subtitle: ProgressBar(
        levelBars: [
          LevelBarDetails(
            fillColor: Theme.of(context).colorScheme.primary,
            currentPoints: points,
          ),
        ],
        progressBarDetails: ProgressBarDetails(
          pointsPerLevel: 20,
          totalWidth: width * 0.75,
          borderColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}
