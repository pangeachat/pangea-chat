import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/widgets/chat/game_leaderboard.dart';
import 'package:fluffychat/pangea/widgets/chat/game_state_view.dart';
import 'package:flutter/material.dart';

class GameChatDetailsView extends StatelessWidget {
  final ChatController controller;
  const GameChatDetailsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: FluffyThemes.columnWidth,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          GameStateView(controller),
          const SizedBox(height: 16),
          Expanded(
            child: GameLeaderBoard(room: controller.room),
          ),
        ],
      ),
    );
  }
}
