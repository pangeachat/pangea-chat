import 'dart:async';

import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/extensions/sync_update_extension.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:matrix/matrix.dart';

/// A model of a game round. Manages the round's state and duration.
class GameRoundModel {
  final Duration roundDuration = const Duration(
    seconds: GameConstants.roundLength,
  );
  final Duration afterRoundDuration = const Duration(
    seconds: GameConstants.betweenRoundLength,
  );

  final Room room;

  // All the below state variables are used for sending and managing
  // round start and end times. Once the bot starts doing that, they should be removed.
  late DateTime createdAt;
  Timer? timer;
  StreamSubscription? syncSubscription;
  final List<String> userMessageIDs = [];
  final List<String> botMessageIDs = [];

  GameRoundModel({
    required this.room,
  }) {
    createdAt = DateTime.now();

    // if, on creation, the current round is already ongoing,
    // start the timer (or reset it if the round went over)
    if (currentRoundStart != null) {
      final currentRoundDuration = DateTime.now().difference(
        currentRoundStart!,
      );
      final roundFinished = currentRoundDuration > roundDuration;
      if (roundFinished) endRound();
    }

    // listen to syncs for new bot messages to start and stop rounds
    syncSubscription ??= room.client.onSync.stream.listen(_handleSync);
  }

  GameModel get gameState => GameModel.fromJson(
        room.getState(PangeaEventTypes.storyGame)?.content ?? {},
      );

  DateTime? get currentRoundStart => gameState.currentRoundStartTime;
  DateTime? get previousRoundEnd => gameState.previousRoundEndTime;

  /// Check if a game event is visible in the GUI.
  bool gameEventIsVisibleInGui(Event event) {
    // if it's not a message, it's sent by the GM,
    // or it's sent after the previous round ended
    if (event.type == PangeaEventTypes.storyGame) {
      final bool roundOngoing = gameState.previousRoundEndTime == null;
      final eventState = GameModel.fromJson(event.content);
      return roundOngoing
          ? eventState.currentRoundStartTime == currentRoundStart
          : eventState.previousRoundEndTime == previousRoundEnd;
    }

    return event.type != EventTypes.Message ||
        event.senderId == GameConstants.gameMaster ||
        previousRoundEnd == null ||
        event.originServerTs.isAfter(previousRoundEnd!);
  }

  void _handleSync(SyncUpdate update) {
    final newMessages = update
        .messages(room)
        .where((msg) => msg.originServerTs.isAfter(createdAt))
        .toList();

    final botMessages = newMessages
        .where((msg) => msg.senderId == GameConstants.gameMaster)
        .toList();
    final userMessages = newMessages
        .where((msg) => msg.senderId != GameConstants.gameMaster)
        .toList();

    final hasNewBotMessage = botMessages.any(
      (msg) => !botMessageIDs.contains(msg.eventId),
    );

    if (hasNewBotMessage) {
      if (currentRoundStart == null) {
        startRound();
      } else {
        endRound();
        return;
      }
    }

    if (currentRoundStart != null) {
      for (final message in botMessages) {
        if (!botMessageIDs.contains(message.eventId)) {
          botMessageIDs.add(message.eventId);
        }
      }

      for (final message in userMessages) {
        if (!userMessageIDs.contains(message.eventId)) {
          userMessageIDs.add(message.eventId);
        }
      }
    }
  }

  /// Set the start and end times of the current and previous rounds.
  Future<void> setRoundTimes({
    DateTime? currentRoundStart,
    DateTime? previousRoundEnd,
  }) async {
    final game = GameModel.fromJson(
      room.getState(PangeaEventTypes.storyGame)?.content ?? {},
    );

    game.currentRoundStartTime = currentRoundStart;

    if (previousRoundEnd != null) {
      game.previousRoundEndTime = previousRoundEnd;
    }

    await room.client.setRoomStateWithKey(
      room.id,
      PangeaEventTypes.storyGame,
      '',
      game.toJson(),
    );
  }

  /// Start a new round.
  void startRound() {
    setRoundTimes(
      currentRoundStart: DateTime.now(),
    ).then((_) => timer = Timer(roundDuration, endRound));
  }

  /// End and cleanup after the current round.
  void endRound() {
    syncSubscription?.cancel();
    syncSubscription = null;

    timer?.cancel();
    timer = null;

    setRoundTimes(
      currentRoundStart: null,
      previousRoundEnd: DateTime.now(),
    ).then((_) => timer = Timer(afterRoundDuration, startRound));
  }

  void dispose() {
    syncSubscription?.cancel();
    syncSubscription = null;

    timer?.cancel();
    timer = null;
  }
}
