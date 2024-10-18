import 'dart:io';

import 'package:fluffychat/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class MissingVoiceButton extends StatelessWidget {
  final VoidCallback launchTTSSettings;
  final String targetLangCode;
  final List<String> availableLangCodes;

  const MissingVoiceButton({
    required this.launchTTSSettings,
    required this.targetLangCode,
    required this.availableLangCodes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLanguageAvailable =
        availableLangCodes.contains(targetLangCode);
    if (isLanguageAvailable || !Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppConfig.borderRadius),
        ),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            L10n.of(context)!.voiceNotAvailable,
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: launchTTSSettings,
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(L10n.of(context)!.openVoiceSettings),
          ),
        ],
      ),
    );
  }
}
