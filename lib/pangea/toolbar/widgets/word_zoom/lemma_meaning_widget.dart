import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/pangea/analytics_misc/text_loading_shimmer.dart';
import 'package:fluffychat/pangea/events/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/learning_settings/constants/language_constants.dart';
import 'package:fluffychat/pangea/lemmas/lemma_info_repo.dart';
import 'package:fluffychat/pangea/lemmas/lemma_info_request.dart';
import 'package:fluffychat/pangea/lemmas/lemma_info_response.dart';
import 'package:fluffychat/widgets/matrix.dart';

class LemmaMeaningWidget extends StatefulWidget {
  final PangeaToken token;
  final String langCode;

  const LemmaMeaningWidget({
    super.key,
    required this.token,
    required this.langCode,
  });

  @override
  LemmaMeaningWidgetState createState() => LemmaMeaningWidgetState();
}

class LemmaMeaningWidgetState extends State<LemmaMeaningWidget> {
  bool _editMode = false;
  late TextEditingController _controller;

  String get _lemma => widget.token.lemma.text.isNotEmpty
      ? widget.token.lemma.text
      : widget.token.lemma.form;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LemmaInfoRequest get _request => LemmaInfoRequest(
        lemma: _lemma,
        partOfSpeech: widget.token.pos,

        /// This assumes that the user's L2 is the language of the lemma
        lemmaLang: widget.langCode,
        userL1:
            MatrixState.pangeaController.languageController.userL1?.langCode ??
                LanguageKeys.defaultLanguage,
      );

  Future<LemmaInfoResponse> _lemmaMeaning() => LemmaInfoRepo.get(_request);

  void _toggleEditMode(bool value) => setState(() => _editMode = value);

  Future<void> editLemmaMeaning(String userEdit) async {
    final originalMeaning = await _lemmaMeaning();

    LemmaInfoRepo.set(
      _request,
      LemmaInfoResponse(emoji: originalMeaning.emoji, meaning: userEdit),
    );

    _toggleEditMode(false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LemmaInfoResponse>(
      future: _lemmaMeaning(),
      builder: (context, snapshot) {
        if (_editMode) {
          _controller.text = snapshot.data?.meaning ?? "";
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${L10n.of(context).pangeaBotIsFallible} ${L10n.of(context).whatIsMeaning(_lemma, widget.token.pos)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    minLines: 1,
                    maxLines: 3,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: snapshot.data!.meaning,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _toggleEditMode(false),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(L10n.of(context).cancel),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () =>
                          _controller.text != snapshot.data!.meaning &&
                                  _controller.text.isNotEmpty
                              ? editLemmaMeaning(_controller.text)
                              : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(L10n.of(context).saveChanges),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const TextLoadingShimmer();
        }

        if (snapshot.hasError || snapshot.data == null) {
          debugger(when: kDebugMode);
          return Text(
            snapshot.error.toString(),
            textAlign: TextAlign.center,
          );
        }

        return Flexible(
          child: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: L10n.of(context).doubleClickToEdit,
            child: GestureDetector(
              onLongPress: () => _toggleEditMode(true),
              onDoubleTap: () => _toggleEditMode(true),
              child: Text(
                snapshot.data!.meaning,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
