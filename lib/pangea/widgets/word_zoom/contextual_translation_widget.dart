import 'package:fluffychat/pangea/constants/language_constants.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/repo/lemma_definition_repo.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

class ContextualTranslationWidget extends StatelessWidget {
  final PangeaToken token;
  final String langCode;

  const ContextualTranslationWidget({
    super.key,
    required this.token,
    required this.langCode,
  });

  Future<String> _fetchDefinition() async {
    final LemmaDefinitionRequest lemmaDefReq = LemmaDefinitionRequest(
      lemma: token.lemma.text,
      partOfSpeech: token.pos,

      /// This assumes that the user's L2 is the language of the lemma
      lemmaLang: langCode,
      userL1:
          MatrixState.pangeaController.languageController.userL1?.langCode ??
              LanguageKeys.defaultLanguage,
    );

    final res = await LemmaDictionaryRepo.get(lemmaDefReq);
    return res.definition;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDefinition(),
      builder: (context, snapshot) {
        return Center(
          child: snapshot.hasData
              ? Text(snapshot.data ?? "...")
              : const CircularProgressIndicator.adaptive(),
        );
      },
    );
  }
}
