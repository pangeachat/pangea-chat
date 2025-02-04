// Flutter imports:

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/learning_settings/enums/l2_support_enum.dart';
import 'package:fluffychat/pangea/learning_settings/models/language_model.dart';
import 'package:flutter/material.dart';

import 'flag.dart';

class PLanguageDropdown extends StatefulWidget {
  final List<LanguageModel> languages;
  final LanguageModel? initialLanguage;
  final Function(String)? onChange;
  final bool showMultilingual;
  final bool isL2List;
  final String? hintText;
  final String decorationText;
  final String? error;
  final double? padding;

  const PLanguageDropdown({
    super.key,
    required this.languages,
    required this.onChange,
    this.hintText,
    required this.initialLanguage,
    this.showMultilingual = false,
    required this.decorationText,
    this.isL2List = false,
    this.error,
    this.padding,
  });

  @override
  State<PLanguageDropdown> createState() => _PLanguageDropdownState();
}

class _PLanguageDropdownState extends State<PLanguageDropdown> {
  @override
  Widget build(BuildContext context) {
    final List<LanguageModel> sortedLanguages = widget.languages;
    final String systemLang = Localizations.localeOf(context).languageCode;
    final List<String> languagePriority = [
      systemLang,
      'en',
      'en-us',
      'es',
      'es-mx',
      'es-es',
    ];

    int sortLanguages(LanguageModel a, LanguageModel b) {
      final String aLang = a.langCode.toLowerCase();
      final String bLang = b.langCode.toLowerCase();
      if (aLang == bLang) return 0;

      final int aPriority =
          languagePriority.indexWhere((code) => code == aLang);
      final int bPriority =
          languagePriority.indexWhere((code) => code == bLang);

      if (aPriority != -1 && bPriority != -1) {
        // Both are in the priority list, compare by priority index
        return aPriority - bPriority;
      }

      if (aPriority != -1) {
        // `a` is in the priority list, it comes first
        return -1;
      }

      if (bPriority != -1) {
        // `b` is in the priority list, it comes first
        return 1;
      }

      // Neither is in the priority list, sort alphabetically by display name
      return a.getDisplayName(context)!.compareTo(b.getDisplayName(context)!);
    }

    sortedLanguages.sort((a, b) => sortLanguages(a, b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField2<LanguageModel>(
          decoration: InputDecoration(labelText: widget.decorationText),
          isExpanded: true,
          hint: Text(
            widget.hintText ?? "",
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
          ),
          value: widget.initialLanguage,
          items: [
            if (widget.showMultilingual)
              DropdownMenuItem(
                value: LanguageModel.multiLingual(context),
                child: LanguageDropDownEntry(
                  languageModel: LanguageModel.multiLingual(context),
                  isL2List: widget.isL2List,
                ),
              ),
            ...sortedLanguages.map(
              (languageModel) => DropdownMenuItem(
                value: languageModel,
                child: LanguageDropDownEntry(
                  languageModel: languageModel,
                  isL2List: widget.isL2List,
                ),
              ),
            ),
          ],
          onChanged: widget.onChange != null
              ? (value) => widget.onChange!(value!.langCode)
              : null,
        ),
        AnimatedSize(
          duration: FluffyThemes.animationDuration,
          child: widget.error == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 5,
                  ),
                  child: Text(
                    widget.error!,
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
      padding: const EdgeInsets.only(left: 12, right: 6),
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
