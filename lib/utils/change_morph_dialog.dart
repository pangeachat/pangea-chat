import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/constants/morph_categories_and_labels.dart';
import 'package:fluffychat/pangea/utils/grammar/get_grammar_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../pangea/widgets/common/bot_face_svg.dart';

Future<dynamic> changeMorphDialog(
  BuildContext context,
  String morphologicalFeature,
  String morphologicalTag,
  void Function(String) submitFeedback,
) {
  final List<String> possibleTags =
      getLabelsForMorphCategory(morphologicalFeature);

  final TextEditingController feedbackController = TextEditingController();
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          L10n.of(context).reportContentIssueTitle,
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BotFace(
                  width: 60,
                  expression: BotExpression.addled,
                ),
                const SizedBox(height: 10),
                Text(L10n.of(context).reportContentIssueDescription),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppConfig.warning,
                    ),
                  ),
                  child: Text(getGrammarCopy(
                          category: morphologicalFeature,
                          lemma: morphologicalTag,
                          context: context) ??
                      morphologicalTag),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: feedbackController,
                  decoration: InputDecoration(
                    labelText: L10n.of(context).feedback,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions:
            possibleTags.where((tag) => tag != morphologicalTag).map((tag) {
          return TextButton(
            onPressed: () {
              submitFeedback(tag);
              Navigator.of(context).pop();
            },
            child: Text(tag),
          );
        }).toList(),
      );
    },
  );
}
