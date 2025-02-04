import 'package:fluffychat/pangea/learning_settings/models/language_model.dart';
import 'package:fluffychat/pangea/learning_settings/widgets/p_language_dropdown.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ChangeMessageLangDialog extends StatefulWidget {
  final LanguageModel? initialLanguage;

  const ChangeMessageLangDialog({
    required this.initialLanguage,
    super.key,
  });

  @override
  State<ChangeMessageLangDialog> createState() =>
      ChangeMessageLangDialogState();
}

class ChangeMessageLangDialogState extends State<ChangeMessageLangDialog> {
  LanguageModel? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PLanguageDropdown(
                languages:
                    MatrixState.pangeaController.pLanguageStore.targetOptions,
                onChange: (lang) => setState(() {
                  _selectedLanguage = MatrixState
                      .pangeaController.pLanguageStore
                      .byLangCode(lang);
                }),
                initialLanguage: widget.initialLanguage,
                decorationText: L10n.of(context).changeMessageLanguage,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text(L10n.of(context).cancel),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(_selectedLanguage);
                    },
                    child: Text(L10n.of(context).confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
