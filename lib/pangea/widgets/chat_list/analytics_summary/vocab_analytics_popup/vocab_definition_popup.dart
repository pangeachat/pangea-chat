import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/enum/lemma_category_enum.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/widgets/chat/tts_controller.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/word_audio_button.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class VocabDefinitionPopup extends StatefulWidget {
  final ConstructUses construct;
  final LemmaCategoryEnum type;

  const VocabDefinitionPopup({
    super.key,
    required this.construct,
    required this.type,
  });

  @override
  VocabDefinitionPopupState createState() => VocabDefinitionPopupState();
}

class VocabDefinitionPopupState extends State<VocabDefinitionPopup> {
  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).brightness != Brightness.light
        ? widget.type.color
        : widget.type.darkColor;
    final String? exampleEventID = widget.construct.uses
        .firstWhereOrNull((e) => e.metadata.eventId != null)
        ?.metadata
        .eventId;
    final String category = widget.construct.category;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Scaffold(
            appBar: AppBar(
              //
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // TODO: Make PangeaToken using construct(?),
                  // then use token.getEmoji to find associated emoji
                  Icon(
                    Icons.add_reaction_outlined,
                    size: 25,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    widget.construct.lemma,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(
                    width: 33,
                  ),
                ],
              ),

              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.adaptive.arrow_back_outlined),
                color: textColor,
                onPressed: Navigator.of(context).pop,
              ),
              actions: (exampleEventID != null)
                  ? [
                      // TODO: Make audio button look more like example pic?
                      // Add more space on top and right?
                      WordAudioButton(
                        text: widget.construct.lemma,
                        ttsController: TtsController(),
                        eventID: exampleEventID,
                      ),
                      const SizedBox(width: 5),
                    ]
                  : [],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Symbols.toys_and_games,
                        size: 25,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Text(
                        // TODO: use getGrammarCopy(?) to get full category name
                        // getGrammarCopy(category: category!, lemma: widget.construct.lemma, context: )
                        category,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        width: 33,
                      ),
                    ],
                  ),
                  // Definition:

                  // Forms:

                  // Horizontal divider

                  // XP associated with lemma (seed/green/flower emoji # XP)

                  // Writing icon, green/red dots for writing usage
                  // Three examples of how the word was used

                  // Listening icon, green/red dots for listening exercises

                  // Reading icon, green/red dots for reading exercises
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
