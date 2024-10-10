import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/constants/class_default_values.dart';
import 'package:fluffychat/pangea/constants/language_constants.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/constants/pangea_room_types.dart';
import 'package:fluffychat/pangea/controllers/language_list_controller.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_event.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/models/bot_options_model.dart';
import 'package:fluffychat/pangea/models/games/game_state_model.dart';
import 'package:fluffychat/pangea/models/language_model.dart';
import 'package:fluffychat/pangea/models/space_model.dart';
import 'package:fluffychat/pangea/models/tokens_event_content_model.dart';
import 'package:fluffychat/pangea/pages/games/story_game/game_chat.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
// import markdown.dart
import 'package:html_unescape/html_unescape.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/utils/markdown.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../config/app_config.dart';
import '../../constants/pangea_event_types.dart';
import '../../models/choreo_record.dart';
import '../../models/representation_content_model.dart';
import '../client_extension/client_extension.dart';

part "children_and_parents_extension.dart";
part "events_extension.dart";
part "room_analytics_extension.dart";
part "room_information_extension.dart";
part "room_settings_extension.dart";
part "space_settings_extension.dart";
part "user_permissions_extension.dart";

extension PangeaRoom on Room {
// analytics

  /// Join analytics rooms in space.
  /// Allows teachers to join analytics rooms without being invited.
  Future<void> joinAnalyticsRoomsInSpace() async =>
      await _joinAnalyticsRoomsInSpace();

  Future<void> addAnalyticsRoomToSpace(Room analyticsRoom) async =>
      await _addAnalyticsRoomToSpace(analyticsRoom);

  /// Add analytics room to all spaces the user is a student in (1 analytics room to all spaces).
  /// Enables teachers to join student analytics rooms via space hierarchy.
  /// Will not always work, as there may be spaces where students don't have permission to add chats,
  /// but allows teachers to join analytics rooms without being invited.
  void addAnalyticsRoomToSpaces() => _addAnalyticsRoomToSpaces();

  /// Add all the user's analytics rooms to 1 space.
  void addAnalyticsRoomsToSpace() => _addAnalyticsRoomsToSpace();

  /// Invite teachers of 1 space to 1 analytics room
  Future<void> inviteSpaceTeachersToAnalyticsRoom(Room analyticsRoom) async =>
      await _inviteSpaceTeachersToAnalyticsRoom(analyticsRoom);

  /// Invite all the user's teachers to 1 analytics room.
  /// Handles case when students cannot add analytics room to space
  /// so teacher is still able to get analytics data for this student.
  void inviteTeachersToAnalyticsRoom() => _inviteTeachersToAnalyticsRoom();

  /// Invite teachers of 1 space to all users' analytics rooms
  void inviteSpaceTeachersToAnalyticsRooms() =>
      _inviteSpaceTeachersToAnalyticsRooms();

  Future<DateTime?> analyticsLastUpdated(String userId) async {
    return await _analyticsLastUpdated(userId);
  }

  Future<List<ConstructAnalyticsEvent>?> getAnalyticsEvents({
    required String userId,
    DateTime? since,
  }) async =>
      await _getAnalyticsEvents(since: since, userId: userId);

  String? get madeForLang => _madeForLang;

  bool isMadeForLang(String langCode) => _isMadeForLang(langCode);

  /// Sends construct events to the server.
  ///
  /// The [uses] parameter is a list of [OneConstructUse] objects representing the
  /// constructs to be sent. To prevent hitting the maximum event size, the events
  /// are chunked into smaller lists. Each chunk is sent as a separate event.
  Future<void> sendConstructsEvent(
    List<OneConstructUse> uses,
  ) async =>
      await _sendConstructsEvent(uses);

  // children_and_parents

  List<Room> get joinedChildren => _joinedChildren;

  List<String> get joinedChildrenRoomIds => _joinedChildrenRoomIds;

  Future<List<Room>> getChildRooms() async => await _getChildRooms();

  Future<void> joinSpaceChild(String roomID) async =>
      await _joinSpaceChild(roomID);

  Room? firstParentWithState(String stateType) =>
      _firstParentWithState(stateType);

  List<Room> get pangeaSpaceParents => _pangeaSpaceParents;

  String nameIncludingParents(BuildContext context) =>
      _nameIncludingParents(context);

  List<String> get allSpaceChildRoomIds => _allSpaceChildRoomIds;

  bool canAddAsParentOf(Room? child, {bool spaceMode = false}) {
    return _canAddAsParentOf(child, spaceMode: spaceMode);
  }

  Future<void> pangeaSetSpaceChild(
    String roomId, {
    bool? suggested,
  }) async =>
      await _pangeaSetSpaceChild(roomId, suggested: suggested);

  /// Returns a map of child suggestion status for a space.
  ///
  /// If the current object is not a space, an empty map is returned.
  /// Otherwise, it iterates through each child in the `spaceChildren` list
  /// and adds their suggestion status to the `suggestionStatus` map.
  /// The suggestion status is determined by the `suggested` property of each child.
  /// If the `suggested` property is `null`, it defaults to `true`.
  Map<String, bool> get spaceChildSuggestionStatus =>
      _spaceChildSuggestionStatus;

  /// Checks if this space has a parent space
  bool get isSubspace => _isSubspace;

// class_and_exchange_settings

  DateTime? get rulesUpdatedAt => _rulesUpdatedAt;

  String get classCode => _classCode;

  void checkClass() => _checkClass();

  List<User> get students => _students;

  Future<List<User>> get teachers async => await _teachers;

  /// Synchronous version of teachers getter. Does not request
  /// participants, so this list may not be complete.
  List<User> get teachersLocal => _teachersLocal;

  /// If the user is an admin of this space, and the space's
  /// m.space.child power level hasn't yet been set, so it to 0
  Future<void> setClassPowerLevels() async => await _setClassPowerLevels();

  Event? get pangeaRoomRulesStateEvent => _pangeaRoomRulesStateEvent;

  Future<List<LanguageModel>> targetLanguages() async =>
      await _targetLanguages();

// events

  Future<bool> leaveIfFull() async => await _leaveIfFull();
  Future<void> archive() async => await _archive();

  Future<bool> archiveSpace(
    BuildContext context,
    Client client, {
    bool onlyAdmin = false,
  }) async =>
      await _archiveSpace(context, client, onlyAdmin: onlyAdmin);

  Future<void> archiveSubspace() async => await _archiveSubspace();

  Future<bool> leaveSpace(BuildContext context, Client client) async =>
      await _leaveSpace(context, client);

  Future<void> leaveSubspace() async => await _leaveSubspace();

  Future<Event?> sendPangeaEvent({
    required Map<String, dynamic> content,
    required String parentEventId,
    required String type,
  }) async =>
      await _sendPangeaEvent(
        content: content,
        parentEventId: parentEventId,
        type: type,
      );

  Future<String?> pangeaSendTextEvent(
    String message, {
    String? txid,
    Event? inReplyTo,
    String? editEventId,
    bool parseMarkdown = true,
    bool parseCommands = false,
    String msgtype = MessageTypes.Text,
    String? threadRootEventId,
    String? threadLastEventId,
    PangeaRepresentation? originalSent,
    PangeaRepresentation? originalWritten,
    PangeaMessageTokens? tokensSent,
    PangeaMessageTokens? tokensWritten,
    ChoreoRecord? choreo,
  }) =>
      _pangeaSendTextEvent(
        message,
        txid: txid,
        inReplyTo: inReplyTo,
        editEventId: editEventId,
        parseMarkdown: parseMarkdown,
        parseCommands: parseCommands,
        msgtype: msgtype,
        threadRootEventId: threadRootEventId,
        threadLastEventId: threadLastEventId,
        originalSent: originalSent,
        originalWritten: originalWritten,
        tokensSent: tokensSent,
        tokensWritten: tokensWritten,
        choreo: choreo,
      );

  Future<String> updateStateEvent(Event stateEvent) =>
      _updateStateEvent(stateEvent);

// room_information

  Future<int> get numNonAdmins async => await _numNonAdmins;

  DateTime? get creationTime => _creationTime;

  String? get creatorId => _creatorId;

  String get domainString => _domainString;

  bool isChild(String roomId) => _isChild(roomId);

  bool isFirstOrSecondChild(String roomId) => _isFirstOrSecondChild(roomId);

  bool get isDirectChatWithoutMe => _isDirectChatWithoutMe;

  // bool isMadeForLang(String langCode) => _isMadeForLang(langCode);

  Future<bool> get isBotRoom async => await _isBotRoom;

  Future<bool> get isBotDM async => await _isBotDM;

  bool get isLocked => _isLocked;

  bool isAnalyticsRoomOfUser(String userId) => _isAnalyticsRoomOfUser(userId);

  bool get isAnalyticsRoom => _isAnalyticsRoom;

// room_settings

  Future<void> updateRoomCapacity(int newCapacity) =>
      _updateRoomCapacity(newCapacity);

  int? get capacity => _capacity;

  PangeaRoomRules? get pangeaRoomRules => _pangeaRoomRules;

  PangeaRoomRules? get firstRules => _firstRules;

  IconData? get roomTypeIcon => _roomTypeIcon;

  Text nameAndRoomTypeIcon([TextStyle? textStyle]) =>
      _nameAndRoomTypeIcon(textStyle);

  BotOptionsModel? get botOptions => _botOptions;

  Future<void> setSuggested(bool suggested) async =>
      await _setSuggested(suggested);

  Future<bool> isSuggested() async => await _isSuggested();

// user_permissions

  Future<bool> isOnlyAdmin() async => await _isOnlyAdmin();

  bool isMadeByUser(String userId) => _isMadeByUser(userId);

  bool get isSpaceAdmin => _isSpaceAdmin;

  bool isUserRoomAdmin(String userId) => _isUserRoomAdmin(userId);

  bool isUserSpaceAdmin(String userId) => _isUserSpaceAdmin(userId);

  bool get isRoomOwner => _isRoomOwner;

  bool get isRoomAdmin => _isRoomAdmin;

  bool get showClassEditOptions => _showClassEditOptions;

  bool get canDelete => _canDelete;

  bool get canIAddSpaceParents => _canIAddSpaceParents;

  bool pangeaCanSendEvent(String eventType) => _pangeaCanSendEvent(eventType);

  int? get eventsDefaultPowerLevel => _eventsDefaultPowerLevel;

  GameModel get gameState =>
      GameModel.fromJson(getState(PangeaEventTypes.storyGame)?.content ?? {});

  bool get isActiveRound =>
      gameState.timerStarts != null &&
      gameState.timerEnds != null &&
      gameState.timerEnds!.isAfter(DateTime.now()) &&
      gameState.timerStarts!.isBefore(DateTime.now());

  bool isEventVisibleInGame(Event event, Timeline timeline) {
    if (!{
      EventTypes.Message,
      EventTypes.Sticker,
      EventTypes.Encrypted,
      EventTypes.CallInvite,
      PangeaEventTypes.storyGame,
    }.contains(event.type)) return true;
    if (event.type == PangeaEventTypes.storyGame) {
      return true;
    }

    if (!event.isGMMessage) {
      // event in this scope will be sent by the bot

      // player suggestions are events sent by user that suggests what the
      // character should say. These are the messages that will be voted on.
      if (!isPlayerSuggestions(event.eventId)) {
        return false;
      }

      // event in this scope from this point on are player suggestions

      // renders the event in timeline if
      // state "playerMessageVisibleFrom" is not set
      if (gameState.playerMessageVisibleFrom == null) {
        return true;
      }

      // do not render the event if it was sent before the
      // playerMessageVisibleFrom state
      if (event.originServerTs.isBefore(gameState.playerMessageVisibleFrom!)) {
        return false;
      }

      // event in this scope from this point on are player suggestions that
      // are sent after the playerMessageVisibleFrom state

      // if playerMessageVisibleTo is not set, render the event
      if (gameState.playerMessageVisibleTo == null) {
        return true;
      }

      // do not render the event if it was sent after the
      // playerMessageVisibleTo state
      if (event.originServerTs.isAfter(gameState.playerMessageVisibleTo!)) {
        return false;
      }

      // otherwise, render the event cuz its within the visible range
      return true;
    }

    // event in this scope from this point on are sent by the bot

    if (event.isCharacterSuggestionMessage) {
      // event in this scope from this point on are messages sent by the bot
      // when it is suggesting what the character should say

      // render the event if the characterOptionMessageVisibleFrom state
      // is not set
      if (gameState.characterOptionMessageVisibleFrom == null) {
        return true;
      }

      // do not render the event if it was sent before the
      // characterOptionMessageVisibleFrom state
      if (event.originServerTs
          .isBefore(gameState.characterOptionMessageVisibleFrom!)) {
        return false;
      }

      // render the event if the characterOptionMessageVisibleTo state
      // is not set
      if (gameState.playerMessageVisibleTo == null) {
        return true;
      }

      // do not render the event if it was sent after the
      // characterOptionMessageVisibleTo state
      if (event.originServerTs.isAfter(gameState.playerMessageVisibleTo!)) {
        return false;
      }

      // otherwise, render the event cuz its within the visible range
      return true;
    }

    // character option messages are messages sent by game master
    // that users can vote on to decide what the character should they
    // be role playing as. This if statement handles if those messages
    // should be rendered in the timeline
    if (gameState.characterOptionMessageIds != null &&
        gameState.characterOptionMessageIds!.contains(event.eventId)) {
      // renders the event in timeline if the state
      // "characterOptionMessageVisibleFrom" is not set
      if (gameState.characterOptionMessageVisibleFrom == null) {
        return true;
      }

      // do not render the event if it was sent before the
      // characterOptionMessageVisibleFrom state
      if (event.originServerTs
          .isBefore(gameState.characterOptionMessageVisibleFrom!)) {
        return false;
      }

      // render the event if the characterOptionMessageVisibleTo state
      // is not set
      if (gameState.characterOptionMessageVisibleTo == null) {
        return true;
      }

      // do not render the event if it was sent after the
      // characterOptionMessageVisibleTo state
      if (event.originServerTs
          .isAfter(gameState.characterOptionMessageVisibleTo!)) {
        return false;
      }

      // otherwise, render the event cuz its within the visible range
      return true;
    }

    // scene option messages are messages sent by game master
    // that users can vote on to decide what the scene should be
    // about. This if statement handles if those messages should be
    // rendered in the timeline
    if (gameState.sceneOptionMessageIds != null &&
        gameState.sceneOptionMessageIds!.contains(event.eventId)) {
      // renders the event in timeline if the state
      // "sceneOptionMessageVisibleFrom" is not set
      if (gameState.sceneOptionMessageVisibleFrom == null) {
        return true;
      }

      // do not render the event if it was sent before the
      // sceneOptionMessageVisibleFrom state
      if (event.originServerTs
          .isBefore(gameState.sceneOptionMessageVisibleFrom!)) {
        return false;
      }

      // render the event if the sceneOptionMessageVisibleTo state
      // is not set
      if (gameState.sceneOptionMessageVisibleTo == null) {
        return true;
      }

      // do not render the event if it was sent after the
      // sceneOptionMessageVisibleTo state
      if (event.originServerTs
          .isAfter(gameState.sceneOptionMessageVisibleTo!)) {
        return false;
      }

      // otherwise, render the event cuz its within the visible range
      return true;
    }

    // illustration messages are images and it should not be hidden
    if (event.messageType == MessageTypes.Image) {
      return true;
    }

    // instruction messages are messages sent by the game master
    // that are instructions for the game. This if statement handles
    // if those messages should be rendered in the timeline
    if (event.isInstructions) {
      // renders the event in timeline if the state
      // "instructionMessageVisibleFrom" is not set
      if (gameState.instructionMessageVisibleFrom == null) {
        return true;
      }

      // do not render the event if it was sent before the
      // instructionMessageVisibleFrom state
      if (event.originServerTs
          .isBefore(gameState.instructionMessageVisibleFrom!)) {
        return false;
      }

      // render the event if the instructionMessageVisibleTo state
      // is not set
      if (gameState.instructionMessageVisibleTo == null) {
        return true;
      }

      // do not render the event if it was sent after the
      // instructionMessageVisibleTo state
      if (event.originServerTs
          .isAfter(gameState.instructionMessageVisibleTo!)) {
        return false;
      }

      // otherwise, render the event cuz its within the visible range
      return true;
    }

    // render the event if it's not a candidate message nor a game master
    // message nor an instruction message nor a character option message nor
    // a scene option message nor an illustration message
    return true;
  }

  bool isPlayerSuggestions(String eventID) =>
      candidateMessageIDs.contains(eventID);

  List<String> get candidateMessageIDs =>
      gameState.characterMessages.values.expand((e) => e).toList();

  List<Event> get candidateMessages {
    if (timeline == null) return [];
    return timeline!.events
        .where((event) => candidateMessageIDs.contains(event.eventId))
        .toList();
  }

  bool userHasVotedThisRound(String userID) {
    for (final message in candidateMessages) {
      final allUserVotes = message
          .aggregatedEvents(timeline!, RelationshipTypes.reaction)
          .where((event) => event.senderId == userID && event.isVote)
          .toList();
      if (allUserVotes.isNotEmpty) return true;
    }
    return false;
  }

  /// Boolean indicating whether the user has voted during the current round.
  bool get hasVotedThisRound {
    if (client.userID == null) return false;
    return userHasVotedThisRound(client.userID!);
  }

  /// Determines whether to show a vote warning based on a given [emoji].
  ///
  /// Returns `true` if the [emoji] is a valid vote emoji and the vote instructions have not been toggled off,
  /// and the user has already voted during the current round.
  // bool shouldShowVoteWarning(String emoji) {
  //   if (!GameConstants.voteEmojis.contains(emoji)) return false;
  //   final instructionsController = MatrixState.pangeaController.instructions;
  //   final bool showedWarning = instructionsController.wereInstructionsShown(
  //     InstructionsEnum.voteInstructions.toString(),
  //   );
  //   if (showedWarning) return false;
  //   return hasVotedThisRound;
  // }

  // /// Send a reaction to a story game event. Redacts all
  // /// previous votes by the user during the active round.
  // Future<void> sendStoryGameReaction(String eventID, String emoji) async {
  //   // if it's not a vote reaction, just send it
  //   if (!GameConstants.voteEmojis.contains(emoji) || timeline == null) {
  //     await sendReaction(eventID, emoji);
  //     return;
  //   }

  //   // If the vote warning popup was showing, close it
  //   MatrixState.pAnyState.closeOverlay();

  //   // Redact all previous votes by the user during the active round
  //   final List<Future> redactFutures = [];
  //   for (final event in timeline!.events) {
  //     if (!sentDuringRound(event)) break;
  //     if (event.type != EventTypes.Message) continue;

  //     final allMyVotes = event
  //         .aggregatedEvents(timeline!, RelationshipTypes.reaction)
  //         .where((event) => event.senderId == client.userID && event.isVote)
  //         .toList();

  //     if (allMyVotes.isEmpty) continue;
  //     redactFutures.addAll(
  //       allMyVotes.map((voteEvent) => voteEvent.redactEvent()),
  //     );
  //   }

  //   await Future.wait(redactFutures);
  //   await sendReaction(eventID, emoji);
  // }
}
