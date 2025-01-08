import 'package:collection/collection.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/constants/language_constants.dart';
import 'package:fluffychat/pangea/constants/morph_categories_and_labels.dart';
import 'package:fluffychat/pangea/enum/activity_type_enum.dart';
import 'package:fluffychat/pangea/enum/construct_use_type_enum.dart';
import 'package:fluffychat/pangea/enum/lemma_category_enum.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/models/lemma.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/models/pangea_token_text_model.dart';
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
  final int points;

  const VocabDefinitionPopup({
    super.key,
    required this.construct,
    required this.type,
    required this.points,
  });

  @override
  VocabDefinitionPopupState createState() => VocabDefinitionPopupState();
}

class VocabDefinitionPopupState extends State<VocabDefinitionPopup> {
  String? exampleEventID;
  LemmaDefinitionResponse? res;
  late Future<String?> definition;
  String? emoji;
  PangeaToken? token;
  String? morphFeature;
  // Lists of lemma uses for the given exercise types; true if positive XP
  List<bool> writingUses = [];
  List<bool> hearingUses = [];
  List<bool> readingUses = [];
  late Future<List<Widget>> writingExamples;

  @override
  void initState() {
    definition = getDefinition();
    writingExamples = getExamples(loadUses());
    final ConstructListModel constructsModel =
        MatrixState.pangeaController.getAnalytics.constructListModel;
    // Find selected emoji, if applicable, using PangeaToken.getEmoji
    emoji = PangeaToken(
      text: PangeaTokenText(
        offset: 0,
        content: widget.construct.lemma,
        length: widget.construct.lemma.length,
      ),
      lemma: Lemma(
        text: widget.construct.lemma,
        saveVocab: false,
        form: widget.construct.lemma,
      ),
      pos: widget.construct.category,
      morph: {},
    ).getEmoji();
    morphFeature = token?.morph.entries.first.key;

    exampleEventID = widget.construct.uses
        .firstWhereOrNull((e) => e.metadata.eventId != null)
        ?.metadata
        .eventId;
    super.initState();
  }

  List<OneConstructUse> loadUses() {
    final List<OneConstructUse> writingUsesDetailed = [];
    for (final OneConstructUse use in widget.construct.uses) {
      final bool positive = use.useType.pointValue > 0;
      final ActivityTypeEnum activityType = use.useType.activityType;
      // TODO: Check with someone that grouping is correct
      switch (activityType) {
        case ActivityTypeEnum.lemmaId:
        case ActivityTypeEnum.morphId:
          writingUses.add(positive);
          writingUsesDetailed.add(use);
          break;
        case ActivityTypeEnum.wordFocusListening:
        case ActivityTypeEnum.hiddenWordListening:
          hearingUses.add(positive);
          break;
        case ActivityTypeEnum.wordMeaning:
          readingUses.add(positive);
          break;
        case ActivityTypeEnum.emoji:
          break;
      }
    }
    return writingUsesDetailed;
  }

  // Wrapping row of dots - green if positive usage, red if negative
  Widget getUsageDots(List<bool> uses) {
    final List<Widget> dots = [];
    for (final bool use in uses) {
      dots.add(
        Container(
          width: 15.0,
          height: 15.0,
          decoration: BoxDecoration(
            color: use ? AppConfig.success : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Wrap(
      spacing: 3,
      runSpacing: 5,
      children: dots,
    );
  }

  Future<List<Widget>> getExamples(
    List<OneConstructUse> writingUsesDetailed,
  ) async {
    final List<Widget> examples = [];
    for (final OneConstructUse use in widget.construct.uses) {
      if (examples.length >= 3) {
        return examples;
      }
      if (use.metadata.eventId == null) {
        continue;
      }
      // TODO: This is absurdly slow.
      // There has got to be a faster way to do this
      // final String? messageText =
      //     (await (MatrixState().client.getRoomById(use.metadata.roomId))
      //             ?.getEventById(use.metadata.eventId!))
      //         ?.text;

      // if (messageText != null) {
      //   examples.add(
      //     const SizedBox(
      //       height: 5,
      //     ),
      //   );
      //   examples.add(
      //     Container(
      //       decoration: BoxDecoration(
      //         color: widget.type.color,
      //         borderRadius: BorderRadius.circular(
      //           4,
      //         ),
      //       ),
      //       padding: const EdgeInsets.symmetric(
      //         horizontal: 16,
      //         vertical: 8,
      //       ),
      //       constraints: const BoxConstraints(
      //         maxWidth: FluffyThemes.columnWidth * 1.5,
      //       ),
      //       child: Text(
      //         messageText,
      //         style: const TextStyle(
      //           color: Colors.black,
      //         ),
      //       ),
      //     ),
      //   );
      // }
    }
    return examples;
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (emoji != null)
                    Text(
                      emoji!,
                    ),
                  if (emoji == null)
                    Tooltip(
                      message: L10n.of(context).noEmojiSelectedTooltip,
                      child: Icon(
                        Icons.add_reaction_outlined,
                        size: 25,
                        color: textColor.withValues(alpha: 0.7),
                      ),
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
                ],
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.adaptive.arrow_back_outlined),
                color: textColor,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: Navigator.of(context).pop,
              ),
              actions: (exampleEventID != null)
                  ? [
                      Column(
                        children: [
                          const SizedBox(height: 6),
                          WordAudioButton(
                            text: widget.construct.lemma,
                            ttsController: TtsController(),
                            eventID: exampleEventID!,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ]
                  : [],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: L10n.of(context).grammarCopyPOS,
                        child: Icon(
                          // TODO: use POS specific icon
                          // morphFeature doesn't work because this is Vocab analytics, not Morph
                          (morphFeature != null)
                              ? getIconForMorphFeature(morphFeature!)
                              : Symbols.toys_and_games,
                          size: 23,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        // TODO: use getGrammarCopy to get full category name
                        // widget.construct.category doesn't work as parameter of getGrammarCopy
                        // Is this also a vocab vs morph problem?
                        // getGrammarCopy(
                        //       category: ,
                        //       lemma: widget.construct.lemma,
                        //       context: context,
                        //     ) ??
                        widget.construct.category,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: FutureBuilder(
                      future: definition,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<String?> snapshot,
                      ) {
                        if (snapshot.hasData) {
                          return RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      L10n.of(context).definitionSectionHeader,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: "  ${snapshot.data!}"),
                              ],
                            ),
                          );
                        } else {
                          return Wrap(
                            children: [
                              Text(
                                L10n.of(context).definitionSectionHeader,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Align(
                    alignment: Alignment.topLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: L10n.of(context).formSectionHeader,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // TODO: Fetch forms using constructListModel from GetAnalyticsController
                          // What function is supposed to do that?
                          // Started code on line 55
                          const TextSpan(
                            text: "  Example forms....",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Divider(
                    height: 3,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${widget.type.emoji} ${widget.points} XP",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Writing exercise section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: L10n.of(context).writingExercisesTooltip,
                        child: Icon(
                          Symbols.edit_square,
                          size: 25,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      getUsageDots(writingUses),
                    ],
                  ),

                  FutureBuilder(
                    future: writingExamples,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<Widget>> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: snapshot.data!,
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
                    height: 20,
                  ),
                  // Listening exercise section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: L10n.of(context).listeningExercisesTooltip,
                        child: Icon(
                          Icons.hearing,
                          size: 25,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      getUsageDots(hearingUses),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Reading exercise section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: L10n.of(context).readingExercisesTooltip,
                        child: Icon(
                          Symbols.two_pager,
                          size: 25,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      getUsageDots(readingUses),
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
