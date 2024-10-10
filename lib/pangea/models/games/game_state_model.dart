import 'dart:developer';

import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:matrix/matrix_api_lite/generated/model.dart';

// enum StoryGamePhase {
//   beginProgressStory,
//   endProgressStory,
//   beginPlayerCompetes,
//   endPlayerCompetes,
//   beginDecideWinner,
//   endDecideWinner,
//   beginWaitNextRound,
//   endWaitNextRound,
//   beginEndGame,
//   endEndGame,
// }

// extension StoryGamePhaseExtension on StoryGamePhase {
//   String get key {
//     switch (this) {
//       case StoryGamePhase.beginProgressStory:
//         return "begin_progress_story";
//       case StoryGamePhase.endProgressStory:
//         return "end_progress_story";
//       case StoryGamePhase.beginPlayerCompetes:
//         return "begin_player_competes";
//       case StoryGamePhase.endPlayerCompetes:
//         return "end_player_competes";
//       case StoryGamePhase.beginDecideWinner:
//         return "begin_decide_winner";
//       case StoryGamePhase.endDecideWinner:
//         return "end_decide_winner";
//       case StoryGamePhase.beginWaitNextRound:
//         return "begin_wait_next_round";
//       case StoryGamePhase.endWaitNextRound:
//         return "end_wait_next_round";
//       case StoryGamePhase.beginEndGame:
//         return "begin_end_game";
//       case StoryGamePhase.endEndGame:
//         return "end_end_game";
//     }
//   }

//   String string(BuildContext context) {
//     switch (this) {
//       case StoryGamePhase.beginProgressStory:
//       case StoryGamePhase.endProgressStory:
//         return L10n.of(context)!.startingNextRound;
//       case StoryGamePhase.beginPlayerCompetes:
//       case StoryGamePhase.endPlayerCompetes:
//         return L10n.of(context)!.competing;
//       case StoryGamePhase.beginDecideWinner:
//       case StoryGamePhase.endDecideWinner:
//         return L10n.of(context)!.choosingPath;
//       case StoryGamePhase.beginWaitNextRound:
//       case StoryGamePhase.endWaitNextRound:
//         return L10n.of(context)!.waitingForNextRound;
//       case StoryGamePhase.beginEndGame:
//       case StoryGamePhase.endEndGame:
//         return L10n.of(context)!.gameOver;
//     }
//   }
// }

// StoryGamePhase? getStoryGamePhase(String? phase) {
//   switch (phase) {
//     case "begin_progress_story":
//       return StoryGamePhase.beginProgressStory;
//     case "end_progress_story":
//       return StoryGamePhase.endProgressStory;
//     case "begin_player_competes":
//       return StoryGamePhase.beginPlayerCompetes;
//     case "end_player_competes":
//       return StoryGamePhase.endPlayerCompetes;
//     case "begin_decide_winner":
//       return StoryGamePhase.beginDecideWinner;
//     case "end_decide_winner":
//       return StoryGamePhase.endDecideWinner;
//     case "begin_wait_next_round":
//       return StoryGamePhase.beginWaitNextRound;
//     case "end_wait_next_round":
//       return StoryGamePhase.endWaitNextRound;
//     case "begin_end_game":
//       return StoryGamePhase.beginEndGame;
//     case "end_end_game":
//       return StoryGamePhase.endEndGame;
//     default:
//       return null;
//   }
// }

class GameModel {
  // // Round States
  // final String? currentCharacter;
  // final String? currentCharacterText;
  // final DateTime? startTime;
  // final DateTime? endPreviousRoundTime;
  // final StoryGamePhase? phase;
  // final bool isGameEnd;
  // // final String? judge;
  // final DateTime? timerEnds;
  // final String? timerText;
  // final DateTime? timerStarts;

  // // Settings States
  // final int delayBeforeNextRoundSeconds;
  // final int roundSeconds;
  // final int? maxRounds;

  // // Story States
  // final String? storyDescription;
  // final String? goalState;
  // final String? failState;
  // final String? goalStateCharacterText;
  // final String? failStateCharacterText;

  final Map<String, int> playerScores;
  Map<String, List<String>> characterMessages = {};
  String? timerText;
  DateTime? timerStarts;
  DateTime? timerEnds;
  String? playerCharacter;
  String? timerPositionAfterEventID;
  DateTime? playerMessageVisibleFrom;
  DateTime? playerMessageVisibleTo;
  List<String>? characterOptionMessageIds;
  List<String>? sceneOptionMessageIds;
  DateTime? sceneOptionMessageVisibleFrom;
  DateTime? sceneOptionMessageVisibleTo;
  DateTime? characterOptionMessageVisibleFrom;
  DateTime? characterOptionMessageVisibleTo;
  DateTime? instructionMessageVisibleFrom;
  DateTime? instructionMessageVisibleTo;

  GameModel({
    // this.currentCharacter,
    // this.currentCharacterText,
    // this.startTime,
    // this.endPreviousRoundTime,
    // this.phase,
    // this.isGameEnd = false,
    // this.delayBeforeNextRoundSeconds = 10,
    // this.roundSeconds = GameConstants.timerMaxSeconds,
    // this.maxRounds,
    // this.storyDescription,
    // this.goalState,
    // this.failState,
    // this.goalStateCharacterText,
    // this.failStateCharacterText,
    // // this.judge,
    // this.timerEnds,
    // this.timerText,
    // this.timerStarts,
    this.playerScores = const {},
    this.characterMessages = const {},
    this.timerText,
    this.timerStarts,
    this.timerEnds,
    this.playerCharacter,
    this.timerPositionAfterEventID,
    this.playerMessageVisibleFrom,
    this.playerMessageVisibleTo,
    this.characterOptionMessageIds,
    this.sceneOptionMessageIds,
    this.characterOptionMessageVisibleFrom,
    this.characterOptionMessageVisibleTo,
    this.sceneOptionMessageVisibleFrom,
    this.sceneOptionMessageVisibleTo,
    this.instructionMessageVisibleFrom,
    this.instructionMessageVisibleTo,
  });

  factory GameModel.fromJson(json) {
    final Map<String, List<String>> msgs = {};
    if (json[ModelKey.characterMessages] != null) {
      final entries =
          (json[ModelKey.characterMessages] as Map<String, dynamic>).entries;

      for (final entry in entries) {
        final List<String> ids = entry.value.cast<String>();
        msgs[entry.key] = ids;
      }
    }
    return GameModel(
      characterMessages: msgs,
      timerText: json[ModelKey.timerText],
      timerStarts: json[ModelKey.timerStarts] != null
          ? DateTime.parse(json[ModelKey.timerStarts])
          : null,
      timerEnds: json[ModelKey.timerEnds] != null
          ? DateTime.parse(json[ModelKey.timerEnds])
          : null,
      playerCharacter: json[ModelKey.playerCharacter],
      playerScores: json[ModelKey.playerScores] != null
          ? Map<String, int>.from(json[ModelKey.playerScores])
          : {},
      timerPositionAfterEventID: json[ModelKey.timerPositionAfterEventID],
      playerMessageVisibleFrom: json[ModelKey.playerMessageVisibleFrom] != null
          ? DateTime.parse(json[ModelKey.playerMessageVisibleFrom])
          : null,
      playerMessageVisibleTo: json[ModelKey.playerMessageVisibleTo] != null
          ? DateTime.parse(json[ModelKey.playerMessageVisibleTo])
          : null,
      sceneOptionMessageIds: json[ModelKey.sceneOptionMessageIds] != null
          ? List<String>.from(json[ModelKey.sceneOptionMessageIds])
          : null,
      sceneOptionMessageVisibleFrom:
          json[ModelKey.sceneOptionMessageVisibleFrom] != null
              ? DateTime.parse(json[ModelKey.sceneOptionMessageVisibleFrom])
              : null,
      sceneOptionMessageVisibleTo:
          json[ModelKey.sceneOptionMessageVisibleTo] != null
              ? DateTime.parse(json[ModelKey.sceneOptionMessageVisibleTo])
              : null,
      characterOptionMessageIds:
          json[ModelKey.characterOptionMessageIds] != null
              ? List<String>.from(json[ModelKey.characterOptionMessageIds])
              : null,
      characterOptionMessageVisibleFrom:
          json[ModelKey.characterOptionMessageVisibleFrom] != null
              ? DateTime.parse(json[ModelKey.characterOptionMessageVisibleFrom])
              : null,
      characterOptionMessageVisibleTo:
          json[ModelKey.characterOptionMessageVisibleTo] != null
              ? DateTime.parse(json[ModelKey.characterOptionMessageVisibleTo])
              : null,
      instructionMessageVisibleFrom:
          json[ModelKey.instructionMessageVisibleFrom] != null
              ? DateTime.parse(json[ModelKey.instructionMessageVisibleFrom])
              : null,
      instructionMessageVisibleTo:
          json[ModelKey.instructionMessageVisibleTo] != null
              ? DateTime.parse(json[ModelKey.instructionMessageVisibleTo])
              : null,

      // currentCharacter: json[ModelKey.currentCharacter],
      // currentCharacterText: json[ModelKey.currentCharacterText],
      // startTime: json[ModelKey.startTime] != null
      //     ? DateTime.parse(json[ModelKey.startTime])
      //     : null,
      // endPreviousRoundTime: json[ModelKey.endPreviousRoundTime] != null
      //     ? DateTime.parse(json[ModelKey.endPreviousRoundTime])
      //     : null,
      // phase: json[ModelKey.phase] != null
      //     ? getStoryGamePhase(json[ModelKey.phase])
      //     : null,
      // isGameEnd: json[ModelKey.isGameEnd] ?? false,
      // delayBeforeNextRoundSeconds:
      //     json[ModelKey.delayBeforeNextRoundSeconds] ?? 10,
      // roundSeconds:
      //     json[ModelKey.roundSeconds] ?? GameConstants.timerMaxSeconds,
      // maxRounds: json[ModelKey.maxRounds],
      // storyDescription: json[ModelKey.storyDescription],
      // goalState: json[ModelKey.goalState],
      // failState: json[ModelKey.failState],
      // goalStateCharacterText: json[ModelKey.goalStateCharacterText],
      // failStateCharacterText: json[ModelKey.failStateCharacterText],
      // // judge: json[ModelKey.judge],
      // timerStarts: json[ModelKey.timerStarts] != null
      //     ? DateTime.parse(json[ModelKey.timerStarts])
      //     : null,
      // timerEnds: json[ModelKey.timerEnds] != null
      //     ? DateTime.parse(json[ModelKey.timerEnds])
      //     : null,
      // timerText: json[ModelKey.timerText],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    try {
      data[ModelKey.characterMessages] = characterMessages;
      data[ModelKey.timerStarts] = timerStarts?.toIso8601String();
      data[ModelKey.timerEnds] = timerEnds?.toIso8601String();
      data[ModelKey.timerText] = timerText;
      data[ModelKey.playerCharacter] = playerCharacter;
      data[ModelKey.playerScores] = playerScores;
      data[ModelKey.timerPositionAfterEventID] = timerPositionAfterEventID;
      data[ModelKey.playerMessageVisibleFrom] =
          playerMessageVisibleFrom?.toIso8601String();
      data[ModelKey.playerMessageVisibleTo] =
          playerMessageVisibleTo?.toIso8601String();
      data[ModelKey.characterOptionMessageIds] = characterOptionMessageIds;
      data[ModelKey.sceneOptionMessageIds] = sceneOptionMessageIds;
      data[ModelKey.instructionMessageVisibleFrom] =
          instructionMessageVisibleFrom?.toIso8601String();
      data[ModelKey.instructionMessageVisibleTo] =
          instructionMessageVisibleTo?.toIso8601String();

      // data[ModelKey.currentCharacter] = currentCharacter;
      // data[ModelKey.currentCharacterText] = currentCharacterText;
      // data[ModelKey.startTime] = startTime?.toIso8601String();
      // data[ModelKey.endPreviousRoundTime] =
      //     endPreviousRoundTime?.toIso8601String();
      // data[ModelKey.phase] = phase?.key;
      // data[ModelKey.isGameEnd] = isGameEnd;
      // data[ModelKey.delayBeforeNextRoundSeconds] = delayBeforeNextRoundSeconds;
      // data[ModelKey.roundSeconds] = roundSeconds;
      // data[ModelKey.maxRounds] = maxRounds;
      // data[ModelKey.storyDescription] = storyDescription;
      // data[ModelKey.goalState] = goalState;
      // data[ModelKey.failState] = failState;
      // data[ModelKey.goalStateCharacterText] = goalStateCharacterText;
      // data[ModelKey.failStateCharacterText] = failStateCharacterText;
      // // data[ModelKey.judge] = judge;
      // data[ModelKey.timerEnds] = timerEnds?.toIso8601String();
      // data[ModelKey.timerStarts] = timerStarts?.toIso8601String();
      // data[ModelKey.timerText] = timerText;
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
