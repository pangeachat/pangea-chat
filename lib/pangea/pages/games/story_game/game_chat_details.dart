import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/widgets/chat/game_leaderboard.dart';
import 'package:flutter/material.dart';

class GameChatDetailsView extends StatelessWidget {
  final ChatController controller;
  const GameChatDetailsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: GameLeaderBoard(room: controller.room),
          ),
        ],
      ),
    );
  }
}
