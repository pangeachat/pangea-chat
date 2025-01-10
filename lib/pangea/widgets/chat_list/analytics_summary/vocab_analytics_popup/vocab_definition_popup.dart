import 'package:collection/collection.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/constants/language_constants.dart';
import 'package:fluffychat/pangea/constants/morph_categories_and_labels.dart';
import 'package:fluffychat/pangea/enum/construct_use_type_enum.dart';
import 'package:fluffychat/pangea/enum/lemma_category_enum.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/models/lemma.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/models/pangea_token_text_model.dart';
import 'package:fluffychat/pangea/repo/lemma_info/lemma_info_repo.dart';
import 'package:fluffychat/pangea/repo/lemma_info/lemma_info_request.dart';
import 'package:fluffychat/pangea/repo/lemma_info/lemma_info_response.dart';
import 'package:fluffychat/pangea/utils/grammar/get_grammar_copy.dart';
import 'package:fluffychat/pangea/widgets/chat/tts_controller.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/word_audio_button.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:matrix/matrix.dart';

/// Displays information about selected lemma and word usage
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
  LemmaInfoResponse? res;
  late Future<String?> definition;
  String? emoji;
  PangeaToken? token;
  String? morphFeature;
  // Lists of lemma uses for the given exercise types; true if positive XP
  List<bool> writingUses = [];
  List<bool> hearingUses = [];
  List<bool> readingUses = [];
  late Future<List<Widget>> writingExamples;
  Set<String>? forms;
  String? formString;

  @override
  void initState() {
    debugPrint("Category: ${widget.construct.category}");
    definition = getDefinition();
    writingExamples = getExamples(loadUses());

    // Get possible forms of lemma
    final ConstructListModel constructsModel =
        MatrixState.pangeaController.getAnalytics.constructListModel;
    forms = (constructsModel.lemmasToUses())[widget.construct.lemma]
        ?.first
        .uses
        .map((e) => e.form)
        .whereType<String>()
        .toSet();

    // Save forms as string
    if (forms != null) {
      formString = "  ";
      for (final String form in forms!) {
        if (form.isNotEmpty) {
          formString = "${formString!}$form, ";
        }
      }
      if (formString!.length <= 2) {
        formString = null;
      } else {
        formString = formString!.substring(0, formString!.length - 2);
      }
    }

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

    exampleEventID = widget.construct.uses
        .firstWhereOrNull((e) => e.metadata.eventId != null)
        ?.metadata
        .eventId;
    super.initState();
  }

  /// Sort uses of lemma associated with writing, reading, and listening.
  List<OneConstructUse> loadUses() {
    final List<OneConstructUse> writingUsesDetailed = [];
    for (final OneConstructUse use in widget.construct.uses) {
      if (use.useType.pointValue == 0) {
        continue;
      }
      final bool positive = use.useType.pointValue > 0;
      final ConstructUseTypeEnum activityType = use.useType;
      switch (activityType) {
        case ConstructUseTypeEnum.wa:
        case ConstructUseTypeEnum.ga:
        case ConstructUseTypeEnum.unk:
        case ConstructUseTypeEnum.corIt:
        case ConstructUseTypeEnum.ignIt:
        case ConstructUseTypeEnum.incIt:
        case ConstructUseTypeEnum.corIGC:
        case ConstructUseTypeEnum.ignIGC:
        case ConstructUseTypeEnum.incIGC:
        case ConstructUseTypeEnum.corL:
        case ConstructUseTypeEnum.ignL:
        case ConstructUseTypeEnum.incL:
        case ConstructUseTypeEnum.corM:
        case ConstructUseTypeEnum.ignM:
        case ConstructUseTypeEnum.incM:
          writingUses.add(positive);
          writingUsesDetailed.add(use);
          break;
        case ConstructUseTypeEnum.corWL:
        case ConstructUseTypeEnum.ignWL:
        case ConstructUseTypeEnum.incWL:
        case ConstructUseTypeEnum.corHWL:
        case ConstructUseTypeEnum.ignHWL:
        case ConstructUseTypeEnum.incHWL:
          hearingUses.add(positive);
          break;
        case ConstructUseTypeEnum.corPA:
        case ConstructUseTypeEnum.ignPA:
        case ConstructUseTypeEnum.incPA:
          readingUses.add(positive);
          break;
        default:
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
    final Set<String> exampleText = {};
    final List<Widget> examples = [];
    for (final OneConstructUse use in writingUsesDetailed) {
      if (examples.length >= 3) {
        return examples;
      }
      if (use.metadata.eventId == null) {
        continue;
      }
      final Room? room = MatrixState.pangeaController.matrixState.client
          .getRoomById(use.metadata.roomId);
      final Event? event = await room?.getEventById(use.metadata.eventId!);
      final String? messageText = event?.text;

      if (messageText != null) {
        // Save text to set, to avoid duplicate entries
        exampleText.add(messageText);
      }
    }
    // Turn message text into widgets:
    for (final String text in exampleText) {
      examples.add(
        const SizedBox(
          height: 5,
        ),
      );
      examples.add(
        Container(
          decoration: BoxDecoration(
            color: widget.type.color,
            borderRadius: BorderRadius.circular(
              4,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          constraints: const BoxConstraints(
            maxWidth: FluffyThemes.columnWidth * 1.5,
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    return examples;
  }

  Future<String?> getDefinition() async {
    final lang2 =
        MatrixState.pangeaController.languageController.userL2?.langCode;
    if (lang2 == null) {
      debugPrint("No lang2, cannot retrieve definition");
      return L10n.of(context).meaningNotFound;
    }

    final LemmaInfoRequest lemmaDefReq = LemmaInfoRequest(
      partOfSpeech: widget.construct.category,
      lemmaLang: lang2,
      userL1:
          MatrixState.pangeaController.languageController.userL1?.langCode ??
              LanguageKeys.defaultLanguage,
      lemma: widget.construct.lemma,
    );
    res = await LemmaInfoRepo.get(lemmaDefReq);
    return res?.meaning;
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
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: L10n.of(context).grammarCopyPOS,
                          child: Icon(
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
                          getGrammarCopy(
                                category: "pos",
                                lemma: widget.construct.category,
                                context: context,
                              ) ??
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: L10n.of(context).meaningSectionHeader,
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
                                  L10n.of(context).meaningSectionHeader,
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
                            TextSpan(
                              text: formString ??
                                  "  ${L10n.of(context).formsNotFound}",
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
      ),
    );
  }
}