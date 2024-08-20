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

  Alignment messageAlignment(Event event) {
    if (event.messageType == MessageTypes.Image) {
      return Alignment.center;
    }

    final ownMessage = event.senderId == userID;
    final character = event.content[ModelKey.character] as String?;
    final isGM = event.senderId == GameConstants.gameMaster;
    if (!isStoryGameMode || !isGM) {
      return ownMessage ? Alignment.topRight : Alignment.topLeft;
    }

    return character == ModelKey.narrator
        ? Alignment.center
        : Alignment.topLeft;
  }

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
    if (event.senderId != GameConstants.gameMaster &&
        nextEvent.senderId != GameConstants.gameMaster) {
      return event.senderId == nextEvent.senderId;
    }
    if (event.senderId == GameConstants.gameMaster &&
        nextEvent.senderId == GameConstants.gameMaster) {
      final character = event.content[ModelKey.character] as String?;
      final nextCharacter = nextEvent.content[ModelKey.character] as String?;
      return character == nextCharacter;
    }
    return false;
  }

  Widget storyGameAvatar(
    Event event,
    Event? nextEvent,
  ) {
    if (event.senderId != room.client.userID &&
        event.senderId != GameConstants.gameMaster &&
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

    final String? character = event.content[ModelKey.character] as String?;
    if (character == null ||
        character == ModelKey.narrator ||
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
    return Avatar(name: character);
  }

  String storyGameDisplayName(Event event) {
    if (event.senderId != GameConstants.gameMaster) {
      return timeline != null && event.isRevealed(timeline!)
          ? event.senderFromMemoryOrFallback.calcDisplayname()
          : "?";
    }

    final character = event.content[ModelKey.character] as String?;
    if (character == ModelKey.narrator || character == null) return "";
    return character;
  }

  BorderRadius storyGameBorderRadius(
    Event event,
    Event? nextEvent,
    bool previousEventSameSender,
  ) {
    const hardCorner = Radius.circular(4);
    const roundedCorner = Radius.circular(AppConfig.borderRadius);

    final character = event.content[ModelKey.character] as String?;
    final ownMessage = event.senderId == userID;
    final nextEventSameSender = storyGameNextEventSameSender(event, nextEvent);

    return character == ModelKey.narrator
        ? const BorderRadius.all(hardCorner)
        : BorderRadius.only(
            topLeft:
                !ownMessage && nextEventSameSender ? hardCorner : roundedCorner,
            topRight:
                ownMessage && nextEventSameSender ? hardCorner : roundedCorner,
            bottomLeft: !ownMessage && previousEventSameSender
                ? hardCorner
                : roundedCorner,
            bottomRight: ownMessage && previousEventSameSender
                ? hardCorner
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
}

extension StoryGameEvent on Event {
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
}
