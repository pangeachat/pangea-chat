import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/pangea/models/games/round_model.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

extension GameChatController on ChatController {
  String? get userID => room.client.userID;

  Alignment messageAlignment(Event event, bool isNarration) {
    final ownMessage = event.senderId == userID;
    if (isNarration) return Alignment.center;
    // if (!isStoryGameMode) {
    return ownMessage ? Alignment.topRight : Alignment.topLeft;
    // }
    // return Alignment.topLeft;
  }

  /// Recursive function that sets the current round, waits for it to
  /// finish, sets it, etc. until the chat view is no longer mounted.
  void setRound() {
    currentRound?.dispose();
    currentRound = GameRoundModel(room: room);
    room.client.onRoomState.stream.firstWhere((update) {
      if (update.roomId != roomId) return false;
      if (update.state is! Event) return false;
      if ((update.state as Event).type != PangeaEventTypes.storyGame) {
        return false;
      }

      final game = GameModel.fromJson((update.state as Event).content);
      return game.previousRoundEndTime != null;
    }).then((_) {
      if (mounted) setRound();
    });
  }
}
