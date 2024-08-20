import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/constants/model_keys.dart';
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
    if (event.content[ModelKey.winner] == null ||
        event.content[ModelKey.winner] == BotName.byEnvironment ||
        event.content[ModelKey.character] == null) {
      return const SizedBox.shrink();
    }
    final winnerID = event.content[ModelKey.winner] as String;
    final User? winner = event.room.getParticipants().firstWhereOrNull(
          (u) => u.id == winnerID,
        );
    final senderName =
        winner?.calcDisplayname() ?? winnerID.localpart ?? winnerID;

    final character = event.content[ModelKey.character] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        L10n.of(context)!.sentByUser(senderName),
        style: TextStyle(
          fontSize: 12,
          color: (Theme.of(context).brightness == Brightness.light
              ? character.color
              : character.lightColorText),
        ),
      ),
    );
  }
}
