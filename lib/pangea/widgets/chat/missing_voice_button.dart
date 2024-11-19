import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';

class MissingVoiceButton extends StatelessWidget {
  const MissingVoiceButton({super.key});

  Future<void> launchTTSSettings(BuildContext context) async {
    if (!kIsWeb && Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'com.android.settings.TTS_SETTINGS',
        package: 'com.talktolearn.chat',
      );

      await showFutureLoadingDialog(
        context: context,
        future: intent.launch,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isAndroid) {
      return const SizedBox();
    }

    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          AppConfig.primaryColor.withOpacity(0.1),
        ),
      ),
      onPressed: () async {
        MatrixState.pAnyState.closeOverlay();
        await launchTTSSettings(context);
      },
      child: Center(
        child: Text(L10n.of(context)!.openVoiceSettings),
      ),
    );
  }
}
