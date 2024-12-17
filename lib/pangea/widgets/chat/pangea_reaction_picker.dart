import 'package:fluffychat/config/app_emojis.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/widgets/chat/message_selection_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class PangeaReactionsPicker extends StatelessWidget {
  final ChatController controller;
  final MessageOverlayController? overlayController;

  const PangeaReactionsPicker(
    this.controller,
    this.overlayController, {
    super.key,
  });

  PangeaToken? get token => overlayController?.selectedToken;

  Future<List<String>> get emojiForToken =>
      token?.getEmojiChoices() ?? Future.value(AppEmojis.emojis);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (controller.showEmojiPicker) return const SizedBox.shrink();
    final display = controller.editEvent == null &&
        controller.replyEvent == null &&
        controller.room.canSendDefaultMessages &&
        controller.selectedEvents.isNotEmpty;

    if (!display) {
      return const SizedBox.shrink();
    }
    final emojis = List<String>.from(AppEmojis.emojis);
    final allReactionEvents = controller.selectedEvents.first
        .aggregatedEvents(
          controller.timeline!,
          RelationshipTypes.reaction,
        )
        .where(
          (event) =>
              event.senderId == event.room.client.userID &&
              event.type == 'm.reaction',
        );

    for (final event in allReactionEvents) {
      try {
        emojis.remove(event.content.tryGetMap('m.relates_to')!['key']);
      } catch (_) {}
    }
    return Flexible(
      child: Row(
        children: [
          Flexible(
            child: FutureBuilder<List<String>>(
              future: emojiForToken,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final emojis = List<String>.from(snapshot.data!);

                for (final event in allReactionEvents) {
                  try {
                    emojis.remove(
                      event.content.tryGetMap('m.relates_to')!['key'],
                    );
                  } catch (_) {}
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: emojis
                        .map(
                          (emoji) => InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => controller.sendEmojiAction(emoji),
                            child: Container(
                              width: kIsWeb ? 56 : 48,
                              alignment: Alignment.center,
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
          // InkWell(
          //   borderRadius: BorderRadius.circular(8),
          //   child: Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 8),
          //     width: 36,
          //     height: 56,
          //     decoration: BoxDecoration(
          //       color: theme.colorScheme.onInverseSurface,
          //       shape: BoxShape.circle,
          //     ),
          //     child: const Icon(Icons.add_outlined),
          //   ),
          //   onTap: () => controller.pickEmojiReactionAction(allReactionEvents),
          // ),
        ],
      ),
    );
  }
}
