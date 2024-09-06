import 'package:emoji_proposal/emoji_proposal.dart';
import 'package:emojis/src/emoji.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/app_emojis.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import '../../config/themes.dart';

class ReactionsPicker extends StatelessWidget {
  final ChatController controller;

  const ReactionsPicker(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.showEmojiPicker) return const SizedBox.shrink();
    final display = controller.editEvent == null &&
        controller.replyEvent == null &&
        controller.room.canSendDefaultMessages &&
        controller.selectedEvents.isNotEmpty;
    // #Pangea
    // Set of emojis the user can react with in story game
    // TODO: Use user-specific emoji list to get this
    final Set<Emoji> emojiList = {};
    final List<String> emojiCodes = [
      '\u{1F44D}',
      '\u{1F44E}',
      '\u{2B50}',
      '\u{1F440}',
      '\u{1F3DE}',
      '\u{1F3DC}',
      '\u{1F305}',
      '\u{1F304}',
      '\u{1F306}',
      '\u{1F307}',
      '\u{1F309}',
      '\u{1F301}',
      '\u{1F3D9}',
      '\u{2764}',
    ];
    for (final code in emojiCodes) {
      final Emoji? emoji = Emoji.byChar(code);
      if (emoji != null) {
        emojiList.add(emoji);
      }
    }
    // Pangea#
    return AnimatedContainer(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
      height: (display) ? 56 : 0,
      child: Material(
        color: Colors.transparent,
        child: Builder(
          builder: (context) {
            if (!display) {
              return const SizedBox.shrink();
            }

            final proposals =
                // #Pangea
                emojiList.isNotEmpty
                    ? emojiList
                    :
                    // Pangea#
                    proposeEmojis(
                        controller.selectedEvents.first.plaintextBody,
                        number: 25,
                        languageCodes:
                            EmojiProposalLanguageCodes.values.toSet(),
                      );
            final emojis = proposals.isNotEmpty
                ? proposals.map((e) => e.char).toList()
                : List<String>.from(AppEmojis.emojis);
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
            return Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(AppConfig.borderRadius),
                      ),
                    ),
                    padding: const EdgeInsets.only(right: 1),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: emojis.length,
                      itemBuilder: (c, i) => InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => controller.sendEmojiAction(emojis[i]),
                        child:
                            // #Pangea
                            // warning icon if the user has already voted this round
                            // and hasn't seen the voting warning yet
                            //   Badge(
                            // offset: const Offset(-5, 5),
                            // backgroundColor: Colors.transparent,
                            // label:
                            //     controller.room.shouldShowVoteWarning(emojis[i])
                            //         ? CircleAvatar(
                            //             radius: 10,
                            //             backgroundColor: Colors.red,
                            //             child: IconButton(
                            //               padding: EdgeInsets.zero,
                            //               icon: const Icon(
                            //                 Icons.error_outline,
                            //                 size: 15,
                            //               ),
                            //               onPressed: () {},
                            //             ),
                            //           )
                            //         : null,
                            // child:
                            // Pangea#
                            Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          child: Text(
                            emojis[i],
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // #Pangea
                // InkWell(
                //   borderRadius: BorderRadius.circular(8),
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 8),
                //     width: 36,
                //     height: 56,
                //     decoration: BoxDecoration(
                //       color: Theme.of(context).colorScheme.onInverseSurface,
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(Icons.add_outlined),
                //   ),
                //   onTap: () =>
                //       controller.pickEmojiReactionAction(allReactionEvents),
                // ),
                // Pangea#
              ],
            );
          },
        ),
      ),
    );
  }
}
