import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/constants/game_constants.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
import 'package:fluffychat/pangea/utils/overlay.dart';
import 'package:fluffychat/pangea/widgets/chat/game_leaderboard.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

extension GameChatController on ChatController {
  String? get userID => room.client.userID;

  bool storyGameNextEventSameSender(Event event, Event? nextEvent) {
    final displayTime = event.type == EventTypes.RoomCreate ||
        nextEvent == null ||
        !event.originServerTs.sameEnvironment(nextEvent.originServerTs);

    final eventRevealed = timeline != null && event.isRevealed(timeline!);
    final nextEventRevealed = timeline != null &&
        nextEvent != null &&
        nextEvent.isRevealed(timeline!);

    if (nextEvent == null ||
        !{
          EventTypes.Message,
          EventTypes.Sticker,
          EventTypes.Encrypted,
        }.contains(nextEvent.type) ||
        displayTime ||
        eventRevealed ||
        nextEventRevealed) return false;

    // if the senders are both not the game master, return whether or not they're the same
    // if sender of one event is the game master, return false
    // if they're both sent by the game master
    //     get the character for both.
    //     if they're the same, return true
    //     if they're different, return false
    if (!event.isGMMessage && !nextEvent.isGMMessage) {
      return event.senderId == nextEvent.senderId;
    }
    if (event.isGMMessage && nextEvent.isGMMessage) {
      return event.character == nextEvent.character;
    }
    return false;
  }

  Widget storyGameAvatar(
    Event event,
    Event? nextEvent,
  ) {
    if (event.senderId != room.client.userID &&
        !event.isGMMessage &&
        timeline != null &&
        event.isRevealed(timeline!)) {
      return FutureBuilder<User?>(
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
    }

    if (event.character == null ||
        event.isNarratorMessage ||
        event.senderId == room.client.userID) {
      return const SizedBox();
    }

    if (storyGameNextEventSameSender(event, nextEvent)) {
      return const SizedBox(
        width: Avatar.defaultSize,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
          ),
        ),
      );
    }
    return Avatar(name: event.character);
  }

  String storyGameDisplayName(Event event) {
    if (!event.isGMMessage) {
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

    if (event.isNarratorMessage) {
      return const BorderRadius.all(hardCorner);
    }

    final rightAlign = characterAlignment(event) == Alignment.topRight;
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        width: 300,
        child: Material(
          child: GameLeaderBoard(room: room, width: 300),
        ),
      ),
      transformTargetId: 'leaderboard_btn',
      backDropToDismiss: false,
      targetAnchor: Alignment.topRight,
      followerAnchor: Alignment.topRight,
    );
  }

  Alignment characterAlignment(Event event) {
    final ownMessage = event.senderId == userID;
    if (!isStoryGameMode) {
      return ownMessage ? Alignment.topRight : Alignment.topLeft;
    }

    if (event.isCandidateMessage) return Alignment.center;
    if (event.character == null) return Alignment.topLeft;
    if (event.isNarratorMessage) return Alignment.center;
    if (characterAlignments.containsKey(event.character)) {
      return characterAlignments[event.character]!;
    }

    characterAlignments[event.character!] = characterAlignments.length % 2 == 0
        ? Alignment.topLeft
        : Alignment.topRight;
    return characterAlignments[event.character]!;
  }
}

extension StoryGameEvent on Event {
  String? get character => content[ModelKey.character] as String?;
  String? get winner => content[ModelKey.winner] as String?;

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
      messageType == MessageTypes.Text && character == null && winner == null;
}
