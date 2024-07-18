import 'package:collection/collection.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/pangea_match_model.dart';
import 'package:fluffychat/pangea/pages/analytics/construct_message_bubble.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/utils/string_color.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class ConstructMessage extends StatelessWidget {
  final PangeaMessageEvent msgEvent;
  final PangeaMatch errorMessage;
  final String lemma;

  const ConstructMessage({
    super.key,
    required this.msgEvent,
    required this.errorMessage,
    required this.lemma,
  });

  @override
  Widget build(BuildContext context) {
    final String? chosen = errorMessage.match.choices
        ?.firstWhereOrNull(
          (element) => element.selected == true,
        )
        ?.value;

    if (chosen == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          ConstructMessageMetadata(msgEvent: msgEvent),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<User?>(
                      future: msgEvent.event.fetchSenderUser(),
                      builder: (context, snapshot) {
                        final displayname = snapshot.data?.calcDisplayname() ??
                            msgEvent.event.senderFromMemoryOrFallback
                                .calcDisplayname();
                        return Text(
                          displayname,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: (Theme.of(context).brightness ==
                                    Brightness.light
                                ? displayname.color
                                : displayname.lightColorText),
                          ),
                        );
                      },
                    ),
                    ConstructMessageBubble(
                      errorText: errorMessage.match.fullText,
                      replacementText: chosen,
                      start: errorMessage.match.offset,
                      end:
                          errorMessage.match.offset + errorMessage.match.length,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConstructMessageMetadata extends StatelessWidget {
  final PangeaMessageEvent msgEvent;

  const ConstructMessageMetadata({
    super.key,
    required this.msgEvent,
  });

  @override
  Widget build(BuildContext context) {
    final String roomName = msgEvent.event.room.getLocalizedDisplayname();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 30, 0),
      child: Column(
        children: [
          Text(
            msgEvent.event.originServerTs.localizedTime(context),
            style: TextStyle(fontSize: 13 * AppConfig.fontSizeFactor),
          ),
          Text(roomName),
        ],
      ),
    );
  }
}
