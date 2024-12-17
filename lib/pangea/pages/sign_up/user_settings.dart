import 'package:fluffychat/pangea/controllers/language_list_controller.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/models/language_model.dart';
import 'package:fluffychat/pangea/pages/sign_up/user_settings_view.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  UserSettingsState createState() => UserSettingsState();
}

class UserSettingsState extends State<UserSettingsPage> {
  PangeaController get _pangeaController => MatrixState.pangeaController;

  LanguageModel? selectedTargetLanguage;

  LanguageModel? get systemLanguage {
    final systemLangCode =
        _pangeaController.languageController.systemLanguage?.langCode;
    return systemLangCode == null
        ? null
        : PangeaLanguage.byLangCode(systemLangCode);
  }

  @override
  void initState() {
    super.initState();
    selectedTargetLanguage = _pangeaController.languageController.userL2;
  }

  void setSelectedTargetLanguage(LanguageModel? language) {
    setState(() {
      selectedTargetLanguage = language;
    });
  }

  Future<void> createUserInPangea() async {
    if (selectedTargetLanguage == null) {
      // TODO THROW ERROR
    }

    final updateFuture = [
      _pangeaController.subscriptionController.reinitialize(),
      _pangeaController.userController.updateProfile(
        (profile) {
          if (systemLanguage != null) {
            profile.userSettings.sourceLanguage = systemLanguage!.langCode;
          }
          profile.userSettings.targetLanguage =
              selectedTargetLanguage!.langCode;
          return profile;
        },
        waitForDataInSync: true,
      ),
    ];
    await Future.wait(updateFuture);
    context.go('/rooms');
  }

  List<LanguageModel> get targetOptions =>
      _pangeaController.pLanguageStore.targetOptions;

  @override
  Widget build(BuildContext context) => UserSettingsView(controller: this);
}
