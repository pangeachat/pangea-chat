import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/pages/games/story_game/game_chat.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/utils/string_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class MessageSentBy extends StatelessWidget {
  final Event event;

  const MessageSentBy({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.winner == null ||
        event.winner == BotName.byEnvironment ||
        event.character == null) {
      return const SizedBox.shrink();
    }

    final User? winner = event.room.getParticipants().firstWhereOrNull(
          (u) => u.id == event.winner,
        );
    final senderName =
        winner?.calcDisplayname() ?? event.winner!.localpart ?? event.winner!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        L10n.of(context)!.sentByUser(senderName),
        style: TextStyle(
          fontSize: 12,
          color: (Theme.of(context).brightness == Brightness.light
              ? event.character?.color
              : event.character?.lightColorText),
        ),
      ),
    );
  }
}
