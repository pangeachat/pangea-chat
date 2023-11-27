// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:fluffychat/pangea/models/language_model.dart';
import '../../widgets/flag.dart';

class PLanguageDropdown extends StatefulWidget {
  final List<LanguageModel> languages;
  final LanguageModel initialLanguage;
  final Function(LanguageModel) onChange;
  final bool showMultilingual;

  const PLanguageDropdown(
      {Key? key,
      required this.languages,
      required this.onChange,
      required this.initialLanguage,
      this.showMultilingual = false})
      : super(key: key);

  @override
  State<PLanguageDropdown> createState() => _PLanguageDropdownState();
}

class _PLanguageDropdownState extends State<PLanguageDropdown> {
  @override
  Widget build(BuildContext context) {
    final List<LanguageModel> sortedLanguages = widget.languages;
    sortedLanguages.sort((a, b) =>
        a.getDisplayName(context)!.compareTo(b.getDisplayName(context)!));

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 0.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: DropdownButton<LanguageModel>(
          // Initial Value
          hint: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: LanguageFlag(
                  language: widget.initialLanguage,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.initialLanguage.getDisplayName(context) ?? "",
                style: const TextStyle().copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: 14),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              )
            ],
          ),

          isExpanded: true,
          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),
          underline: Container(),
          // Array list of items
          items: [
            if (widget.showMultilingual)
              DropdownMenuItem(
                  value: LanguageModel.multiLingual(context),
                  child: LanguageDropDownEntry(
                    languageModel: LanguageModel.multiLingual(context),
                  )),
            ...sortedLanguages
                .map(
                  (languageModel) => DropdownMenuItem(
                      value: languageModel,
                      child: LanguageDropDownEntry(
                        languageModel: languageModel,
                      )),
                )
                .toList()
          ],
          onChanged: (value) => widget.onChange(value!),
        ),
      ),
    );
  }
}

class LanguageDropDownEntry extends StatelessWidget {
  final LanguageModel languageModel;
  const LanguageDropDownEntry({
    Key? key,
    required this.languageModel,
  }) : super(key: key);

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
          Text(
            languageModel.getDisplayName(context) ?? "",
            style: const TextStyle().copyWith(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 14),
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
