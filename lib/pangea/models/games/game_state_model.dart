import 'dart:developer';

import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:matrix/matrix_api_lite/generated/model.dart';

class GameModel {
  DateTime? currentRoundStartTime;
  DateTime? messagesVisibleFrom;
  String? currentCharacter;
  DateTime? messageVisibleTo;
  Map<String, int>? score;
  int nextRoundDelay;

  GameModel({
    this.currentRoundStartTime,
    this.messagesVisibleFrom,
    this.currentCharacter,
    this.messageVisibleTo,
    this.score,
    this.nextRoundDelay = 10,
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
