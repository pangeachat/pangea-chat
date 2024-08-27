import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
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
  Map<String, int>? get currentScore => widget.room.gameState.playerScores;
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

  const UserProgressBar({
    super.key,
    required this.user,
    required this.points,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.calcDisplayname();

    return ListTile(
      onTap: () {},
      leading: Avatar(
        name: displayName,
        mxContent: user.avatarUrl,
        size: 40,
      ),
      title: Text(
        user.calcDisplayname(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
      subtitle: Row(
        children: List.generate(
          GameConstants.pointsToWin,
          (i) => Icon(
            points > i ? Icons.star : Icons.star_border,
            size: 22,
            color: const Color.fromARGB(200, 229, 184, 11),
          ),
        ),
      ),
    );
  }
}

class GameLeaderboardPopup extends StatelessWidget {
  final Room room;
  const GameLeaderboardPopup({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      width: 325,
      child: Stack(
        children: [
          GameLeaderBoard(room: room, width: 300),
          Positioned(
            right: 5,
            top: 5,
            child: SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                iconSize: 16,
                icon: const Icon(Icons.close),
                onPressed: () => MatrixState.pAnyState.closeOverlay(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
