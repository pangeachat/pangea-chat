import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/chat_settings/widgets/language_level_dropdown.dart';
import 'package:fluffychat/pangea/common/constants/model_keys.dart';
import 'package:fluffychat/pangea/common/widgets/full_width_dialog.dart';
import 'package:fluffychat/pangea/learning_settings/models/language_model.dart';
import 'package:fluffychat/pangea/learning_settings/pages/settings_learning.dart';
import 'package:fluffychat/pangea/learning_settings/widgets/country_picker_tile.dart';
import 'package:fluffychat/pangea/learning_settings/widgets/p_language_dropdown.dart';
import 'package:fluffychat/pangea/learning_settings/widgets/p_settings_switch_list_tile.dart';
import 'package:fluffychat/pangea/spaces/models/space_model.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsLearningView extends StatelessWidget {
  final SettingsLearningController controller;
  const SettingsLearningView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Matrix.of(context).client.onSync.stream.where((update) {
        return update.accountData != null &&
            update.accountData!.any(
              (event) => event.type == ModelKey.userProfile,
            );
      }),
      builder: (context, _) {
        final dialogContent = Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              L10n.of(context).learningSettings,
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: Navigator.of(context).pop,
            ),
          ),
          body: ListTileTheme(
            iconColor: Theme.of(context).textTheme.bodyLarge!.color,
            child: Form(
              key: controller.formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            spacing: 16.0,
                            children: [
                              PLanguageDropdown(
                                onChange: (lang) =>
                                    controller.setSelectedLanguage(
                                  sourceLanguage: lang,
                                ),
                                initialLanguage:
                                    controller.selectedSourceLanguage ??
                                        LanguageModel.unknown,
                                languages: MatrixState.pangeaController
                                    .pLanguageStore.baseOptions,
                                isL2List: false,
                                decorationText: L10n.of(context).myBaseLanguage,
                                validator: (lang) {
                                  if (lang ==
                                      controller.selectedTargetLanguage) {
                                    return L10n.of(context)
                                        .noIdenticalLanguages;
                                  }
                                  return null;
                                },
                              ),
                              PLanguageDropdown(
                                onChange: (lang) =>
                                    controller.setSelectedLanguage(
                                  targetLanguage: lang,
                                ),
                                initialLanguage:
                                    controller.selectedTargetLanguage,
                                languages: MatrixState.pangeaController
                                    .pLanguageStore.targetOptions,
                                isL2List: true,
                                decorationText: L10n.of(context).iWantToLearn,
                                validator: (lang) {
                                  if (lang ==
                                      controller.selectedSourceLanguage) {
                                    return L10n.of(context)
                                        .noIdenticalLanguages;
                                  }
                                  return null;
                                },
                              ),
                              LanguageLevelDropdown(
                                initialLevel: controller.cefrLevel,
                                onChanged: controller.setCefrLevel,
                              ),
                              CountryPickerTile(controller),
                              for (final toolSetting in ToolSetting.values
                                  .where((tool) => tool.isAvailableSetting))
                                Column(
                                  children: [
                                    ProfileSettingsSwitchListTile.adaptive(
                                      defaultValue: controller
                                          .getToolSetting(toolSetting),
                                      title: toolSetting.toolName(context),
                                      subtitle: toolSetting ==
                                                  ToolSetting.enableTTS &&
                                              !controller
                                                  .tts.isLanguageFullySupported
                                          ? null
                                          : toolSetting
                                              .toolDescription(context),
                                      onChange: (bool value) =>
                                          controller.updateToolSetting(
                                        toolSetting,
                                        value,
                                      ),
                                      enabled:
                                          toolSetting == ToolSetting.enableTTS
                                              ? controller
                                                  .tts.isLanguageFullySupported
                                              : true,
                                    ),
                                    if (toolSetting == ToolSetting.enableTTS &&
                                        !controller
                                            .tts.isLanguageFullySupported)
                                      ListTile(
                                        trailing: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                          ),
                                          child: Icon(Icons.info_outlined),
                                        ),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            text: L10n.of(context)
                                                .couldNotFindTTS,
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: [
                                              if (PlatformInfos.isWindows ||
                                                  PlatformInfos.isAndroid)
                                                TextSpan(
                                                  text: L10n.of(context)
                                                      .ttsInstructionsHyperlink,
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          launchUrlString(
                                                            PlatformInfos
                                                                    .isWindows
                                                                ? AppConfig
                                                                    .windowsTTSDownloadInstructions
                                                                : AppConfig
                                                                    .androidTTSDownloadInstructions,
                                                          );
                                                        },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              SwitchListTile.adaptive(
                                value: controller.publicProfile,
                                onChanged: controller.setPublicProfile,
                                title: Text(
                                  L10n.of(context).publicProfileTitle,
                                ),
                                subtitle: Text(
                                  L10n.of(context).publicProfileDesc,
                                ),
                                activeColor: AppConfig.activeToggleColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.submit,
                          child: Text(L10n.of(context).submit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        return FullWidthDialog(
          dialogContent: dialogContent,
          maxWidth: 600,
          maxHeight: 800,
        );
      },
    );
  }
}
