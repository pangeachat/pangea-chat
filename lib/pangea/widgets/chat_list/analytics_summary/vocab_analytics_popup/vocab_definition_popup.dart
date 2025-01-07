import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/constants/language_constants.dart';
import 'package:fluffychat/pangea/enum/lemma_category_enum.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/repo/lemma_definition_repo.dart';
import 'package:fluffychat/pangea/widgets/chat/tts_controller.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/word_audio_button.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
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
  String? exampleEventID;
  LemmaDefinitionResponse? res;
  late Future<String?> definition;

  @override
  void initState() {
    definition = getDefinition();

    exampleEventID = widget.construct.uses
        .firstWhereOrNull((e) => e.metadata.eventId != null)
        ?.metadata
        .eventId;
    super.initState();
  }

  Future<String?> getDefinition() async {
    final LemmaDefinitionRequest lemmaDefReq = LemmaDefinitionRequest(
      lemma: widget.construct.lemma,
      partOfSpeech: widget.construct.category,

      /// This assumes that the user's L2 is the language of the lemma
      // TODO: Edit default lemmaLang value?
      lemmaLang:
          MatrixState.pangeaController.languageController.userL2?.langCode ??
              LanguageKeys.defaultLanguage,
      userL1:
          MatrixState.pangeaController.languageController.userL1?.langCode ??
              LanguageKeys.defaultLanguage,
    );
    res = await LemmaDictionaryRepo.get(lemmaDefReq);
    return res?.definition;
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).brightness != Brightness.light
        ? widget.type.color
        : widget.type.darkColor;

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
                        eventID: exampleEventID!,
                      ),
                      const SizedBox(width: 5),
                    ]
                  : [],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                        width: 5,
                      ),
                      Text(
                        // TODO: use getGrammarCopy(?) to get full category name
                        // getGrammarCopy(category: category!, lemma: widget.construct.lemma, context: )
                        widget.construct.category,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      L10n.of(context).definitionSectionHeader,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: definition,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<String?> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            " - ${snapshot.data!}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        );
                      } else {
                        return const CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        );
                      }
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      L10n.of(context).formSectionHeader,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // TODO: How do I retrieve forms?
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "\t- Example forms",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Divider(
                    height: 3,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // TODO: Use earlier points calculation, for more efficient performance?
                  Text(
                    "${widget.type.emoji} ${widget.construct.points} XP",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Symbols.edit_square,
                        size: 25,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      // TODO: Add green/red dots for writing usage
                    ],
                  ),
                  // TODO: Add 3 examples of how the word was used

                  const SizedBox(
                    height: 20,
                  ),

                  // Listening icon, green/red dots for listening exercises
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.hearing,
                        size: 25,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      // TODO: Add green/red dots for writing usage
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // Reading icon, green/red dots for reading exercises
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Symbols.edit_square,
                        size: 25,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      // TODO: Add green/red dots for writing usage
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
