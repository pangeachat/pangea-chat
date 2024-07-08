import 'package:fluffychat/pangea/models/language_model.dart';
import 'package:fluffychat/pangea/widgets/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class AnalyticsLanguageButton extends StatelessWidget {
  final List<LanguageModel> languages;
  final LanguageModel value;
  final void Function(LanguageModel) onChange;
  const AnalyticsLanguageButton({
    super.key,
    required this.value,
    required this.onChange,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LanguageModel>(
      tooltip: L10n.of(context)!.changeAnalyticsLanguage,
      initialValue: value,
      onSelected: (LanguageModel? lang) {
        if (lang == null) {
          debugPrint("when is lang null?");
          return;
        }
        onChange(lang);
      },
      itemBuilder: (BuildContext context) =>
          languages.map((LanguageModel lang) {
        return PopupMenuItem<LanguageModel>(
          value: lang,
          child: Text(lang.getDisplayName(context) ?? lang.langCode),
        );
      }).toList(),
      child: TextButton(
        onPressed: null,
        child: LanguageFlag(
          language: value,
        ),
      ),
    );
  }
}
