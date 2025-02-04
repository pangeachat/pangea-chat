import 'package:fluffychat/pangea/events/event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/events/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/events/models/representation_content_model.dart';
import 'package:fluffychat/pangea/events/models/tokens_event_content_model.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension.dart';
import 'package:fluffychat/pangea/learning_settings/models/language_model.dart';
import 'package:fluffychat/pangea/learning_settings/widgets/flag.dart';
import 'package:fluffychat/pangea/toolbar/widgets/change_message_lang_dialog.dart';
import 'package:fluffychat/pangea/toolbar/widgets/message_selection_overlay.dart';
import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

class ChangeMessageLangButton extends StatelessWidget {
  final PangeaMessageEvent pangeaMessageEvent;
  final MessageOverlayController overlayController;

  const ChangeMessageLangButton({
    required this.pangeaMessageEvent,
    required this.overlayController,
    super.key,
  });

  Future<String?> _updateLanguage(String langCode) async {
    return pangeaMessageEvent.room.pangeaSendTextEvent(
      pangeaMessageEvent.messageDisplayText,
      editEventId: pangeaMessageEvent.eventId,
      originalSent: PangeaRepresentation(
        langCode: langCode,
        text: pangeaMessageEvent.messageDisplayText,
        originalSent: true,
        originalWritten: pangeaMessageEvent.originalWritten == null,
      ),
      originalWritten: pangeaMessageEvent.originalWritten?.content,
      tokensSent: PangeaMessageTokens(
        tokens: pangeaMessageEvent.originalSent!.tokens!
            .map((token) => PangeaToken.fromJson(token.toJson()))
            .toList(),
      ),
      tokensWritten: pangeaMessageEvent.originalWritten?.tokens != null
          ? PangeaMessageTokens(
              tokens: pangeaMessageEvent.originalWritten!.tokens!,
            )
          : null,
      choreo: pangeaMessageEvent.originalSent?.choreo,
    );
  }

  Future<void> _changeMessageLang(BuildContext context) async {
    final LanguageModel? newLang = await showDialog(
      context: context,
      builder: (context) {
        return ChangeMessageLangDialog(
          initialLanguage:
              MatrixState.pangeaController.pLanguageStore.byLangCode(
            pangeaMessageEvent.messageDisplayLangCode,
          ),
        );
      },
    );

    if (newLang == null ||
        newLang.langCode == pangeaMessageEvent.messageDisplayLangCode) {
      return;
    }

    await showFutureLoadingDialog(
      context: context,
      future: () async => _updateLanguage(newLang.langCode),
    );
    overlayController.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _changeMessageLang(context),
      customBorder: const CircleBorder(),
      child: LanguageFlag(
        language: MatrixState.pangeaController.pLanguageStore.byLangCode(
              pangeaMessageEvent.messageDisplayLangCode,
            ) ??
            LanguageModel.unknown,
      ),
    );
  }
}
