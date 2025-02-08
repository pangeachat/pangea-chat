// Flutter imports:

import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/learning_settings/enums/l2_support_enum.dart';
import 'package:fluffychat/pangea/learning_settings/models/language_model.dart';
import 'package:flutter/material.dart';

import 'flag.dart';

class PLanguageDropdown extends StatelessWidget {
  final List<LanguageModel> languages;
  final LanguageModel? initialLanguage;
  final Function(LanguageModel) onChange;
  final bool showMultilingual;
  final bool isL2List;
  final String decorationText;
  final String? error;
  final String? Function(LanguageModel?)? validator;

  const PLanguageDropdown({
    super.key,
    required this.languages,
    required this.onChange,
    required this.initialLanguage,
    this.showMultilingual = false,
    required this.decorationText,
    this.isL2List = false,
    this.error,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final List<LanguageModel> sortedLanguages = languages;
    final String systemLang = Localizations.localeOf(context).languageCode;
    final List<String> languagePriority = [systemLang];

    int sortLanguages(LanguageModel a, LanguageModel b) {
      final String aLang = a.langCode;
      final String bLang = b.langCode;
      if (aLang == bLang) return 0;

      final bool aIsPriority = languagePriority.contains(a.langCode);
      final bool bIsPriority = languagePriority.contains(b.langCode);
      if (!aIsPriority && !bIsPriority) {
        return a.getDisplayName(context)!.compareTo(b.getDisplayName(context)!);
      }

      if (aIsPriority && bIsPriority) {
        final int aPriority = languagePriority.indexOf(a.langCode);
        final int bPriority = languagePriority.indexOf(b.langCode);
        return aPriority - bPriority;
      }

      return aIsPriority ? -1 : 1;
    }

    sortedLanguages.sort((a, b) => sortLanguages(a, b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<LanguageModel>(
          decoration: InputDecoration(labelText: decorationText),
          isExpanded: true,
          items: [
            if (showMultilingual)
              DropdownMenuItem(
                value: LanguageModel.multiLingual(context),
                child: LanguageDropDownEntry(
                  languageModel: LanguageModel.multiLingual(context),
                  isL2List: isL2List,
                ),
              ),
            ...sortedLanguages.map(
              (languageModel) => DropdownMenuItem(
                value: languageModel,
                child: LanguageDropDownEntry(
                  languageModel: languageModel,
                  isL2List: isL2List,
                ),
              ),
            ),
          ],
          onChanged: (value) => onChange(value!),
          value: initialLanguage,
          validator: (value) => validator?.call(value),
        ),
        AnimatedSize(
          duration: FluffyThemes.animationDuration,
          child: error == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 5,
                  ),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class LanguageDropDownEntry extends StatelessWidget {
  final LanguageModel languageModel;
  final bool isL2List;
  const LanguageDropDownEntry({
    super.key,
    required this.languageModel,
    required this.isL2List,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LanguageFlag(
            language: languageModel,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              languageModel.getDisplayName(context) ?? "",
              style: const TextStyle().copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          if (isL2List && languageModel.l2Support != L2SupportEnum.full)
            languageModel.l2Support.toBadge(context),
        ],
      ),
    );
  }
}
