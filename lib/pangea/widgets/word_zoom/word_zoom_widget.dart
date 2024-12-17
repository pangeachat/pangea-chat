import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/widgets/chat/tts_controller.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/multiple_choice_activity.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/word_text_with_audio_button.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/contextual_translation_widget.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/lemma_definition_widget.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/lemma_widget.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/morphological_widget.dart';
import 'package:fluffychat/pangea/widgets/word_zoom/part_of_speech_widget.dart';
import 'package:flutter/material.dart';

class WordZoomWidget extends StatefulWidget {
  final PangeaToken token;
  final PangeaMessageEvent messageEvent;
  final TtsController tts;

  const WordZoomWidget({
    super.key,
    required this.token,
    required this.messageEvent,
    required this.tts,
  });

  @override
  _WordZoomWidgetState createState() => _WordZoomWidgetState();
}

class _WordZoomWidgetState extends State<WordZoomWidget> {
  MultipleChoiceActivity? multipleChoiceActivity;

  @override
  void initState() {
    // setMode();
    super.initState();
  }

  // void setMode() {
  //   if (widget.token.shouldDoActivity(ActivityTypeEnum.wordMeaning)) {
  //     multipleChoiceActivity = MultipleChoiceActivity(
  //       practiceCardController: widget.practiceCardController,
  //       currentActivity: widget.messageEvent.messageActivity!,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          WordTextWithAudioButton(
            text: widget.token.text.content,
            ttsController: widget.tts,
            eventID: widget.messageEvent.eventId,
          ),
          ContextualTranslationWidget(
            token: widget.token,
            fullText: widget.messageEvent.messageDisplayText,
            langCode: widget.messageEvent.messageDisplayLangCode,
          ),
          Wrap(
            children: widget.token.morph.entries
                .map(
                  (entry) => MorphologicalWidget(
                    token: widget.token,
                    morphFeature: entry.key,
                  ),
                )
                .toList(),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LemmaWidget(token: widget.token),
              PartOfSpeechWidget(token: widget.token),
              // TODO - make this widget
              // LemmaProgressWidget(token: widget.token),
            ],
          ),
          LemmaDefinitionWidget(
            token: widget.token,
            tokenLang: widget.messageEvent.messageDisplayLangCode,
          ),
        ],
      ),
    );
  }
}
