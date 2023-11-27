// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

// Project imports:
import 'package:fluffychat/pangea/models/class_model.dart';
import '../../../widgets/matrix.dart';
import '../../constants/language_keys.dart';
import '../../constants/language_level_type.dart';
import '../../constants/pangea_event_types.dart';
import '../../controllers/language_list_controller.dart';
import '../../controllers/pangea_controller.dart';
import '../../extensions/pangea_room_extension.dart';
import '../../models/language_model.dart';
import '../../utils/error_handler.dart';
import '../../utils/language_level_copy.dart';
import '../user_settings/p_language_dropdown.dart';
import '../user_settings/p_question_container.dart';

class ClassSettings extends StatefulWidget {
  final String? roomId;
  final bool startOpen;

  const ClassSettings({Key? key, this.roomId, this.startOpen = false})
      : super(key: key);

  @override
  ClassSettingsState createState() => ClassSettingsState();
}

class ClassSettingsState extends State<ClassSettings> {
  Room? room;
  late ClassSettingsModel classSettings;
  late bool isOpen;
  final PangeaController pangeaController = MatrixState.pangeaController;

  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final schoolController = TextEditingController();

  ClassSettingsState({Key? key});

  @override
  void initState() {
    room = widget.roomId != null
        ? Matrix.of(context).client.getRoomById(widget.roomId!)
        : null;

    classSettings = room?.classSettings ?? ClassSettingsModel();

    isOpen = widget.startOpen;

    super.initState();
  }

  bool get sameLanguages =>
      classSettings.targetLanguage == classSettings.dominantLanguage;

  LanguageModel getLanguage({required bool isBase, required String? langCode}) {
    final LanguageModel backup = isBase
        ? pangeaController.pLanguageStore.baseOptions.first
        : pangeaController.pLanguageStore.targetOptions.first;
    if (langCode == null) return backup;
    final LanguageModel byCode = PangeaLanguage.byLangCode(langCode);
    return byCode.langCode != LanguageKeys.unknownLanguage ? byCode : backup;
  }

  Future<void> updatePermission(void Function() makeLocalRuleChange) async {
    makeLocalRuleChange();
    if (room != null) {
      await showFutureLoadingDialog(
        context: context,
        future: () => setClassSettings(room!.id),
      );
    }
    setState(() {});
  }

  void setTextControllerValues() {
    classSettings.city = cityController.text;
    classSettings.country = countryController.text;
    classSettings.schoolName = schoolController.text;
  }

  Future<void> setClassSettings(String roomId) async {
    try {
      setTextControllerValues();

      await Matrix.of(context).client.setRoomStateWithKey(
            roomId,
            PangeaEventTypes.classSettings,
            '',
            classSettings.toJson(),
          );
    } catch (err, stack) {
      debugger(when: kDebugMode);
      ErrorHandler.logError(e: err, s: stack);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ListTile(
            title: Text(
              L10n.of(context)!.classSettings,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(L10n.of(context)!.classSettingsDesc),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              foregroundColor: Theme.of(context).textTheme.bodyLarge!.color,
              child: const Icon(Icons.language),
            ),
            trailing: Icon(
              isOpen
                  ? Icons.keyboard_arrow_down_outlined
                  : Icons.keyboard_arrow_right_outlined,
            ),
            onTap: () => setState(() => isOpen = !isOpen),
          ),
          if (isOpen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isOpen ? null : 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Column(
                  children: [
                    PQuestionContainer(
                        title:
                            L10n.of(context)!.selectClassRoomDominantLanguage),
                    PLanguageDropdown(
                      onChange: (p0) => updatePermission(() {
                        classSettings.dominantLanguage = p0.langCode;
                      }),
                      initialLanguage: getLanguage(
                        isBase: true,
                        langCode: classSettings.dominantLanguage,
                      ),
                      languages: pangeaController.pLanguageStore.baseOptions,
                      showMultilingual: true,
                    ),
                    PQuestionContainer(
                        title: L10n.of(context)!.selectTargetLanguage),
                    PLanguageDropdown(
                      onChange: (p0) => updatePermission(() {
                        classSettings.targetLanguage = p0.langCode;
                      }),
                      initialLanguage: getLanguage(
                        isBase: false,
                        langCode: classSettings.targetLanguage,
                      ),
                      languages: pangeaController.pLanguageStore.targetOptions,
                    ),
                    PQuestionContainer(
                        title: L10n.of(context)!.whatIsYourClassLanguageLevel),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 0.5,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton(
                          // Initial Value
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              classSettings.languageLevel == null
                                  ? L10n.of(context)!.selectLanguageLevel
                                  : LanguageLevelTextPicker.languageLevelText(
                                      context,
                                      classSettings.languageLevel!,
                                    ),
                              style: const TextStyle().copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          isExpanded: true,
                          underline: Container(),
                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),
                          // Array list of items
                          items:
                              LanguageLevelType.allInts.map((int levelOption) {
                            return DropdownMenuItem(
                              value: levelOption,
                              child: Text(
                                LanguageLevelTextPicker.languageLevelText(
                                    context, levelOption),
                                style: const TextStyle().copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                          onChanged: (int? newValue) => updatePermission(() {
                            classSettings.languageLevel = newValue!;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
}
