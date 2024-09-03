import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/enum/instructions_enum.dart';
import 'package:fluffychat/pangea/utils/overlay.dart';
import 'package:fluffychat/pangea/widgets/chat/game_leaderboard.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

extension GameChatController on ChatController {
  String? get userID => room.client.userID;

  bool storyGameNextEventSameSender(Event event, Event? nextEvent) {
    final eventRevealed = timeline != null && event.isRevealed(timeline!);
    final nextEventRevealed = timeline != null &&
        nextEvent != null &&
        nextEvent.isRevealed(timeline!);

    final displayTime = event.type == EventTypes.RoomCreate ||
        nextEvent == null ||
        !event.originServerTs.sameEnvironment(nextEvent.originServerTs);

    if (nextEvent == null ||
        !{
          EventTypes.Message,
          EventTypes.Sticker,
          EventTypes.Encrypted,
        }.contains(nextEvent.type) ||
        displayTime ||
        eventRevealed ||
        nextEventRevealed) return false;

    if (event.isCandidateMessage && nextEvent.isCandidateMessage) {
      return true;
    }

    if (!event.isGMMessage && !nextEvent.isGMMessage) {
      return event.senderId == nextEvent.senderId;
    }
    if (event.isGMMessage && nextEvent.isGMMessage) {
      return event.character == nextEvent.character;
    }
    return false;
  }

  bool storyGamePreviousEventSameSender(Event event, Event? previousEvent) {
    if (event.isCandidateMessage &&
        (previousEvent?.isCandidateMessage ?? false)) {
      return true;
    }

    return previousEvent != null &&
        {
          EventTypes.Message,
          EventTypes.Sticker,
          EventTypes.Encrypted,
        }.contains(previousEvent.type) &&
        previousEvent.senderId == event.senderId &&
        previousEvent.originServerTs.sameEnvironment(event.originServerTs);
  }

  Widget storyGameAvatar(
    Event event,
    Event? nextEvent,
  ) {
    Widget avatarBody = const SizedBox.shrink();

    // a revealed avatar
    if (event.senderId != room.client.userID &&
        !event.isGMMessage &&
        timeline != null &&
        event.isRevealed(timeline!)) {
      avatarBody = FutureBuilder<User?>(
        future: event.fetchSenderUser(),
        builder: (context, snapshot) {
          final user = snapshot.data ?? event.senderFromMemoryOrFallback;
          return Avatar(
            mxContent: user.avatarUrl,
            name: user.calcDisplayname(),
            presenceUserId: user.stateKey,
          );
        },
      );
    } else if (event.character != null &&
        !event.isNarratorMessage &&
        !storyGameNextEventSameSender(event, nextEvent)) {
      avatarBody = Avatar(name: event.character);
    }

    return SizedBox(
      width: event.messageType == MessageTypes.Image ? 0 : Avatar.defaultSize,
      height: Avatar.defaultSize,
      child: avatarBody,
    );
  }

  String storyGameDisplayName(Event event) {
    if (event.isCandidateMessage) {
      return timeline != null && event.isRevealed(timeline!)
          ? event.senderFromMemoryOrFallback.calcDisplayname()
          : "";
    }

    if (event.isNarratorMessage || event.character == null) return "";
    return event.character!;
  }

  BorderRadius storyGameBorderRadius(
    Event event,
    Event? nextEvent,
    bool previousEventSameSender,
  ) {
    const hardCorner = Radius.circular(4);
    const roundedCorner = Radius.circular(AppConfig.borderRadius);

    if (event.isCandidateMessage) {
      return const BorderRadius.all(roundedCorner);
    }

    if (event.isNarratorMessage || event.isInstructions) {
      return const BorderRadius.all(hardCorner);
    }

    final rightAlign = storyGameAlignment(event) == Alignment.topRight;
    final nextEventSameSender = storyGameNextEventSameSender(event, nextEvent);

    return BorderRadius.only(
      topLeft: rightAlign
          ? roundedCorner
          : previousEventSameSender
              ? hardCorner
              : roundedCorner,
      topRight: rightAlign
          ? previousEventSameSender
              ? hardCorner
              : roundedCorner
          : roundedCorner,
      bottomLeft: rightAlign
          ? roundedCorner
          : nextEventSameSender
              ? hardCorner
              : roundedCorner,
      bottomRight: rightAlign
          ? nextEventSameSender
              ? hardCorner
              : roundedCorner
          : roundedCorner,
    );
  }

  void showLeaderboard() {
    OverlayUtil.showOverlay(
      context: context,
      child: GameLeaderboardPopup(room: room),
      transformTargetId: 'leaderboard_btn',
      backDropToDismiss: false,
      targetAnchor: Alignment.topRight,
      followerAnchor: Alignment.topRight,
    );
  }

  Alignment storyGameAlignment(Event event) {
    final ownMessage = event.senderId == userID;
    if (!isStoryGameMode) {
      return ownMessage ? Alignment.topRight : Alignment.topLeft;
    }

    if (event.isNarratorMessage || event.isInstructions) {
      return Alignment.center;
    }
    if (event.isCandidateMessage) return Alignment.center;
    if (event.character == null) return Alignment.topLeft;
    if (characterAlignments.containsKey(event.character)) {
      return characterAlignments[event.character]!;
    }

    characterAlignments[event.character!] = characterAlignments.length % 2 == 0
        ? Alignment.topLeft
        : Alignment.topRight;
    return characterAlignments[event.character]!;
  }

  CrossAxisAlignment storyGameCrossAxisAlignment(Event event) {
    final alignment = storyGameAlignment(event);
    return alignment == Alignment.topRight
        ? CrossAxisAlignment.end
        : alignment == Alignment.topLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center;
  }

  void showVoteWarning(String eventID) {
    final instructionsController = MatrixState.pangeaController.instructions;
    instructionsController.showInstructionsPopup(
      context,
      InstructionsEnum.voteInstructions,
      eventID,
    );
  }
}

extension StoryGameEvent on Event {
  String? get character => content[ModelKey.character] as String?;
  String? get winner => content[ModelKey.winner] as String?;
  bool get isInstructions => content[ModelKey.isInstructions] == true;

  bool isRevealed(Timeline timeline) {
    final Set<Event> events = aggregatedEvents(
      timeline,
      RelationshipTypes.reaction,
    );
    final reactions = events
        .map(
          (r) => r.content
              .tryGetMap<String, dynamic>('m.relates_to')
              ?.tryGet<String>('key'),
        )
        .toList();
    return reactions.contains('👀');
  }

  bool get isGMMessage => senderId == GameConstants.gameMaster;

  bool get isNarratorMessage => isGMMessage && character == ModelKey.narrator;

  bool get isWinnerMessage => isGMMessage && winner != null;

  bool get isCandidateMessage =>
      messageType == MessageTypes.Text &&
      character == null &&
      winner == null &&
      !isInstructions;

  bool get isVote =>
      type == EventTypes.Reaction &&
      GameConstants.voteEmojis.contains(
        content
            .tryGetMap<String, dynamic>('m.relates_to')
            ?.tryGet<String>('key'),
      );
}
