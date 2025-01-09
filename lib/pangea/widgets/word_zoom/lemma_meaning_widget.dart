import 'dart:developer';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/constants/language_constants.dart';
import 'package:fluffychat/pangea/repo/lemma_info/lemma_info_repo.dart';
import 'package:fluffychat/pangea/repo/lemma_info/lemma_info_request.dart';
import 'package:fluffychat/pangea/widgets/igc/card_error_widget.dart';
import 'package:fluffychat/utils/feedback_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:shimmer/shimmer.dart';

class LemmaMeaningWidget extends StatelessWidget {
  final String lemma;
  final String pos;
  final String langCode;

  const LemmaMeaningWidget({
    super.key,
    required this.lemma,
    required this.pos,
    required this.langCode,
  });

  Future<String> _fetchDefinition([String? feedback]) async {
    final LemmaInfoRequest lemmaDefReq = LemmaInfoRequest(
      lemma: lemma,
      partOfSpeech: pos,

      /// This assumes that the user's L2 is the language of the lemma
      lemmaLang: langCode,
      userL1:
          MatrixState.pangeaController.languageController.userL1?.langCode ??
              LanguageKeys.defaultLanguage,
    );

    final res = await LemmaInfoRepo.get(lemmaDefReq, feedback);
    return res.definition;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDefinition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show a shimmer rectangle to indicate loading text
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!, // Base color of the shimmer effect
            highlightColor:
                Colors.grey[100]!, // Highlight color of the shimmer effect
            child: Container(
              height: AppConfig.messageFontSize * AppConfig.fontSizeFactor,
              width: 80.0, // Width of the rectangle
              color:
                  AppConfig.primaryColor, // Background color of the rectangle
            ),
          );
        }
        debugger(when: snapshot.hasError);
        if (snapshot.hasError) {
          return CardErrorWidget(
            error: L10n.of(context).oopsSomethingWentWrong,
            padding: 0,
            maxWidth: 500,
          );
        }

        return GestureDetector(
          onLongPress: () => showFeedbackDialog(context, _fetchDefinition),
          onDoubleTap: () => showFeedbackDialog(context, _fetchDefinition),
          child: Text(
            snapshot.data as String,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
