import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/controllers/base_controller.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:matrix/matrix.dart';

// This is a controller for the story game. It's a way of maintaining states that need to
// be maintained across the app, even when the chat page is closed.
class StoryGameController extends BaseController {
  late PangeaController _pangeaController;
  StreamSubscription? _syncSubscription;

  StoryGameController(PangeaController pangeaController) {
    _pangeaController = pangeaController;
  }

  Client get client => _pangeaController.matrixState.client;
  Map<String, DateTime> winnerEventTimestamps = {};

  void initialize() {
    _syncSubscription = client.onSync.stream.listen(setWinningEvent);
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _syncSubscription = null;

    super.dispose();
  }

  Future<void> setWinningEvent(SyncUpdate update) async {
    if (update.rooms?.join == null) return;
    for (final entry in update.rooms!.join!.entries) {
      final roomID = entry.key;
      final Room? room = client.getRoomById(roomID);
      if (room == null || room.gameState.startTime == null) continue;

      if (winnerEventTimestamps.containsKey(roomID) &&
          winnerEventTimestamps[roomID]!.isAfter(room.gameState.startTime!)) {
        continue;
      }

      final timelineEvents =
          update.rooms!.join![roomID]!.timeline?.events ?? [];
      if (timelineEvents.isEmpty) return;
      final winnerEvent = timelineEvents.firstWhereOrNull(
        (e) =>
            e.originServerTs.isAfter(room.gameState.startTime!) &&
            e.type == EventTypes.Message &&
            e.content.containsKey(ModelKey.winner),
      );
      if (winnerEvent == null) return;
      winnerEventTimestamps[roomID] = winnerEvent.originServerTs;

      final voters =
          winnerEvent.content[ModelKey.votes] as Map<String, dynamic>?;
      if (voters == null || !voters.containsKey(client.userID)) return;
      final votes = voters[client.userID].cast<String>();
      // TODO award constructs to the logged in user if they voted for the winning message
    }
  }
}
