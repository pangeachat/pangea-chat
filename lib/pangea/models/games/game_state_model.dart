import 'dart:developer';

import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix_api_lite/generated/model.dart';

enum StoryGamePhase {
  beginProgressStory,
  endProgressStory,
  beginPlayerCompetes,
  endPlayerCompetes,
  beginDecideWinner,
  endDecideWinner,
  beginWaitNextRound,
  endWaitNextRound,
  beginEndGame,
  endEndGame,
}

extension StoryGamePhaseExtension on StoryGamePhase {
  String get key {
    switch (this) {
      case StoryGamePhase.beginProgressStory:
        return "begin_progress_story";
      case StoryGamePhase.endProgressStory:
        return "end_progress_story";
      case StoryGamePhase.beginPlayerCompetes:
        return "begin_player_competes";
      case StoryGamePhase.endPlayerCompetes:
        return "end_player_competes";
      case StoryGamePhase.beginDecideWinner:
        return "begin_decide_winner";
      case StoryGamePhase.endDecideWinner:
        return "end_decide_winner";
      case StoryGamePhase.beginWaitNextRound:
        return "begin_wait_next_round";
      case StoryGamePhase.endWaitNextRound:
        return "end_wait_next_round";
      case StoryGamePhase.beginEndGame:
        return "begin_end_game";
      case StoryGamePhase.endEndGame:
        return "end_end_game";
    }
  }

  String string(BuildContext context) {
    switch (this) {
      case StoryGamePhase.beginProgressStory:
      case StoryGamePhase.endProgressStory:
        return L10n.of(context)!.startingNextRound;
      case StoryGamePhase.beginPlayerCompetes:
      case StoryGamePhase.endPlayerCompetes:
        return L10n.of(context)!.competing;
      case StoryGamePhase.beginDecideWinner:
      case StoryGamePhase.endDecideWinner:
        return L10n.of(context)!.choosingPath;
      case StoryGamePhase.beginWaitNextRound:
      case StoryGamePhase.endWaitNextRound:
        return L10n.of(context)!.waitingForNextRound;
      case StoryGamePhase.beginEndGame:
      case StoryGamePhase.endEndGame:
        return L10n.of(context)!.gameOver;
    }
  }
}

StoryGamePhase? getStoryGamePhase(String? phase) {
  switch (phase) {
    case "begin_progress_story":
      return StoryGamePhase.beginProgressStory;
    case "end_progress_story":
      return StoryGamePhase.endProgressStory;
    case "begin_player_competes":
      return StoryGamePhase.beginPlayerCompetes;
    case "end_player_competes":
      return StoryGamePhase.endPlayerCompetes;
    case "begin_decide_winner":
      return StoryGamePhase.beginDecideWinner;
    case "end_decide_winner":
      return StoryGamePhase.endDecideWinner;
    case "begin_wait_next_round":
      return StoryGamePhase.beginWaitNextRound;
    case "end_wait_next_round":
      return StoryGamePhase.endWaitNextRound;
    case "begin_end_game":
      return StoryGamePhase.beginEndGame;
    case "end_end_game":
      return StoryGamePhase.endEndGame;
    default:
      return null;
  }
}

class GameModel {
  DateTime? currentRoundStartTime;
  DateTime? messagesVisibleFrom;
  String? currentCharacter;
  DateTime? messageVisibleTo;
  Map<String, int>? score;
  int nextRoundDelay;
  StoryGamePhase? phase;

  GameModel({
    this.currentRoundStartTime,
    this.messagesVisibleFrom,
    this.currentCharacter,
    this.messageVisibleTo,
    this.score,
    this.nextRoundDelay = 10,
    this.phase,
  });

  factory GameModel.fromJson(json) {
    return GameModel(
      currentRoundStartTime: json[ModelKey.currentRoundStartTime] != null
          ? DateTime.parse(json[ModelKey.currentRoundStartTime])
          : null,
      messagesVisibleFrom: json[ModelKey.messagesVisibleFrom] != null
          ? DateTime.parse(json[ModelKey.messagesVisibleFrom])
          : null,
      currentCharacter: json[ModelKey.currentCharacter],
      messageVisibleTo: json[ModelKey.messagesVisibleTo] != null
          ? DateTime.parse(json[ModelKey.messagesVisibleTo])
          : null,
      score: json[ModelKey.score] != null
          ? Map<String, int>.from(json[ModelKey.score])
          : null,
      nextRoundDelay: json[ModelKey.nextRoundDelay] ?? 10,
      phase: json[ModelKey.phase] != null
          ? getStoryGamePhase(json[ModelKey.phase])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    try {
      data[ModelKey.currentRoundStartTime] =
          currentRoundStartTime?.toIso8601String();
      data[ModelKey.messagesVisibleFrom] =
          messagesVisibleFrom?.toIso8601String();
      data[ModelKey.currentCharacter] = currentCharacter;
      data[ModelKey.messagesVisibleTo] = messageVisibleTo?.toIso8601String();
      data[ModelKey.score] = score;
      data[ModelKey.nextRoundDelay] = nextRoundDelay;
      data[ModelKey.phase] = phase?.key;
      return data;
    } catch (e, s) {
      debugger(when: kDebugMode);
      ErrorHandler.logError(e: e, s: s);
      return data;
    }
  }

  StateEvent get toStateEvent => StateEvent(
        content: toJson(),
        type: PangeaEventTypes.storyGame,
      );
}
