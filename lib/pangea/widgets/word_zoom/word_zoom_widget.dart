import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/controllers/message_analytics_controller.dart';
import 'package:fluffychat/pangea/enum/activity_type_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/utils/grammar/get_grammar_copy.dart';
import 'package:fluffychat/pangea/widgets/chat/message_selection_overlay.dart';
import 'package:fluffychat/pangea/widgets/chat/tts_controller.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/emoji_practice_button.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/practice_activity_card.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/word_text_with_audio_button.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/contextual_translation_widget.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/lemma_widget.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/morphological_widget.dart';
import 'package:flutter/material.dart';

enum WordZoomSelection {
  translation,
  emoji,
  lemma,
  morph,
}

extension on WordZoomSelection {
  ActivityTypeEnum get activityType {
    switch (this) {
      case WordZoomSelection.translation:
        return ActivityTypeEnum.wordMeaning;
      case WordZoomSelection.emoji:
        return ActivityTypeEnum.emoji;
      case WordZoomSelection.lemma:
        return ActivityTypeEnum.lemmaId;
      case WordZoomSelection.morph:
        return ActivityTypeEnum.morphId;
    }
  }
}

class WordZoomWidget extends StatefulWidget {
  final PangeaToken token;
  final PangeaMessageEvent messageEvent;
  final TtsController tts;
  final MessageOverlayController overlayController;

  const WordZoomWidget({
    super.key,
    required this.token,
    required this.messageEvent,
    required this.tts,
    required this.overlayController,
  });

  @override
  WordZoomWidgetState createState() => WordZoomWidgetState();
}

class WordZoomWidgetState extends State<WordZoomWidget> {
  WordZoomSelection _selectionType = WordZoomSelection.translation;
  bool _forceShowActivity = false;

  // morphological activities
  String? _selectedMorphFeature;

  // The function to determine if lemma distractors can be generated
  // is computationally expensive, so we only do it once
  bool canGenerateLemmaActivity = false;

  @override
  void initState() {
    super.initState();
    _setCanGenerateLemmaActivity();
  }

  @override
  void didUpdateWidget(covariant WordZoomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token != oldWidget.token) {
      _clean();
      _setCanGenerateLemmaActivity();
    }
  }

  void _clean() {
    if (mounted) {
      setState(() {
        _selectionType = WordZoomSelection.translation;
        _selectedMorphFeature = null;
        _forceShowActivity = false;
      });
    }
  }

  void _setCanGenerateLemmaActivity() {
    widget.token.canGenerateDistractors(ActivityTypeEnum.lemmaId).then((value) {
      if (mounted) setState(() => canGenerateLemmaActivity = value);
    });
  }

  void setShowActivity(bool showActivity) {
    if (mounted) setState(() => _forceShowActivity = showActivity);
  }

  void _setSelectedMorphFeature(String? feature) {
    _selectedMorphFeature = _selectedMorphFeature == feature ? null : feature;
    _setSelectionType(
      _selectedMorphFeature == null
          ? WordZoomSelection.translation
          : WordZoomSelection.morph,
    );
  }

  void _setSelectionType(WordZoomSelection type) {
    if (mounted) setState(() => _selectionType = type);
  }

  void onActivityFinish({
    required ActivityTypeEnum activityType,
    String? correctAnswer,
  }) {
    switch (activityType) {
      case ActivityTypeEnum.emoji:
        if (correctAnswer == null) return;
        widget.token.setEmoji(correctAnswer).then((_) {
          if (mounted) setState(() {});
        });
        break;
      default:
        break;
    }
  }

  Widget get _wordZoomCenterWidget {
    final showActivity = widget.token.shouldDoActivity(
          a: _selectionType.activityType,
          feature: _selectedMorphFeature,
          tag: _selectedMorphFeature == null
              ? null
              : widget.token.morph[_selectedMorphFeature],
        ) &&
        (_selectionType != WordZoomSelection.lemma || canGenerateLemmaActivity);

    if (showActivity || _forceShowActivity) {
      return PracticeActivityCard(
        pangeaMessageEvent: widget.messageEvent,
        targetTokensAndActivityType: TargetTokensAndActivityType(
          tokens: [widget.token],
          activityType: _selectionType.activityType,
        ),
        overlayController: widget.overlayController,
        morphFeature: _selectedMorphFeature,
        wordDetailsController: this,
      );
    }

    if (_selectionType == WordZoomSelection.translation) {
      return ContextualTranslationWidget(
        token: widget.token,
        langCode: widget.messageEvent.messageDisplayLangCode,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_activityAnswer],
    );
  }

  Widget get _activityAnswer {
    switch (_selectionType) {
      case WordZoomSelection.morph:
        if (_selectedMorphFeature == null) {
          return const Text("There should be a selected morph feature");
        }
        final String morphTag = widget.token.morph[_selectedMorphFeature!];
        final copy = getGrammarCopy(
          category: _selectedMorphFeature!,
          lemma: morphTag,
          context: context,
        );
        return Text(copy ?? morphTag);
      case WordZoomSelection.lemma:
        return Text(widget.token.lemma.text);
      case WordZoomSelection.emoji:
        return widget.token.getEmoji() != null
            ? Text(widget.token.getEmoji()!)
            : const Text("emoji is null");
      case WordZoomSelection.translation:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppConfig.toolbarMinHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: AppConfig.toolbarMinWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmojiPracticeButton(
                      token: widget.token,
                      onPressed: () => _setSelectionType(
                        _selectionType == WordZoomSelection.emoji
                            ? WordZoomSelection.translation
                            : WordZoomSelection.emoji,
                      ),
                      // setEmoji: _setEmoji,
                    ),
                    WordTextWithAudioButton(
                      text: widget.token.text.content,
                      ttsController: widget.tts,
                      eventID: widget.messageEvent.eventId,
                    ),
                    LemmaWidget(
                      token: widget.token,
                      onPressed: () => _setSelectionType(
                        _selectionType == WordZoomSelection.lemma
                            ? WordZoomSelection.translation
                            : WordZoomSelection.lemma,
                      ),
                    ),
                  ],
                ),
              ),
              _wordZoomCenterWidget,
              MorphologicalListWidget(
                token: widget.token,
                setMorphFeature: _setSelectedMorphFeature,
                selectedMorphFeature: _selectedMorphFeature,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
