import 'package:fluffychat/pangea/enum/instructions_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/representation_content_model.dart';
import 'package:fluffychat/pangea/utils/bot_style.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/pangea/utils/inline_tooltip.dart';
import 'package:fluffychat/pangea/widgets/chat/toolbar_content_loading_indicator.dart';
import 'package:fluffychat/pangea/widgets/igc/card_error_widget.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

class MessageTranslationCard extends StatefulWidget {
  final PangeaMessageEvent messageEvent;

  const MessageTranslationCard({
    super.key,
    required this.messageEvent,
  });

  @override
  MessageTranslationCardState createState() => MessageTranslationCardState();
}

class MessageTranslationCardState extends State<MessageTranslationCard> {
  PangeaRepresentation? repEvent;
  String? selectionTranslation;
  String? oldSelectedText;
  bool _fetchingRepresentation = false;

  Future<void> fetchRepresentation() async {
    if (l1Code == null) return;

    repEvent = widget.messageEvent
        .representationByLanguage(
          l1Code!,
        )
        ?.content;

    if (repEvent == null && mounted) {
      repEvent = await widget.messageEvent.representationByLanguageGlobal(
        langCode: l1Code!,
      );
    }
  }

  Future<void> loadTranslation(Future<void> Function() future) async {
    if (!mounted) return;
    setState(() => _fetchingRepresentation = true);
    try {
      await future();
    } catch (err) {
      ErrorHandler.logError(e: err);
    }

    if (mounted) {
      setState(() => _fetchingRepresentation = false);
    }
  }

  String? get l1Code =>
      MatrixState.pangeaController.languageController.activeL1Code();
  String? get l2Code =>
      MatrixState.pangeaController.languageController.activeL2Code();

  @override
  void initState() {
    super.initState();
    loadTranslation(() async {
      await fetchRepresentation();
    });
  }

  void closeHint() {
    MatrixState.pangeaController.instructions.turnOffInstruction(
      InlineInstructions.l1Translation.toString(),
    );
    MatrixState.pangeaController.instructions.updateEnableInstructions(
      InlineInstructions.l1Translation.toString(),
      true,
    );
    setState(() {});
  }

  /// Show warning if message's language code is user's L1
  /// or if translated text is same as original text.
  /// Warning does not show if was previously closed
  bool get showWarning {
    if (MatrixState.pangeaController.instructions.wereInstructionsTurnedOff(
      InlineInstructions.l1Translation.toString(),
    )) return false;

    final bool isWrittenInL1 =
        l1Code != null && widget.messageEvent.originalSent?.langCode == l1Code;
    final bool isTextIdentical = selectionTranslation != null &&
        widget.messageEvent.originalSent?.text == selectionTranslation;

    return isWrittenInL1 || isTextIdentical;
  }

  @override
  Widget build(BuildContext context) {
    if (!_fetchingRepresentation &&
        repEvent == null &&
        selectionTranslation == null) {
      return const CardErrorWidget();
    }

    return Container(
      child: _fetchingRepresentation
          ? const ToolbarContentLoadingIndicator()
          : Column(
              children: [
                selectionTranslation != null
                    ? Text(
                        selectionTranslation!,
                        style: BotStyle.text(context),
                      )
                    : Text(
                        repEvent!.text,
                        style: BotStyle.text(context),
                      ),
                const SizedBox(height: 10),
                if (showWarning)
                  InlineTooltip(
                    body: InlineInstructions.l1Translation.body(context),
                    onClose: closeHint,
                  ),
              ],
            ),
    );
  }
}
