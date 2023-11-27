// Dart imports:
import 'dart:developer';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

// Project imports:
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/choreographer/controllers/choreographer.dart';
import 'package:fluffychat/pangea/models/class_model.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import '../../../widgets/matrix.dart';

class _ErrorCopy {
  final String title;
  final String? description;

  _ErrorCopy(this.title, [this.description]);
}

class LanguagePermissionsButtons extends StatelessWidget {
  final String? roomID;
  final Choreographer choreographer;

  const LanguagePermissionsButtons({
    Key? key,
    required this.roomID,
    required this.choreographer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (roomID == null) return const SizedBox.shrink();
    final _ErrorCopy? copy = getCopy(context);
    if (copy == null) return const SizedBox.shrink();

    final Widget text = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: copy.title,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          if (copy.description != null)
            TextSpan(
              text: copy.description,
              style: const TextStyle(color: AppConfig.primaryColor),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.go('/rooms/settings/learning'),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 56.0),
      child: FloatingActionButton(
        mini: true,
        child: const Icon(Icons.history_edu_outlined),
        onPressed: () => showMessage(context, text),
      ),
    );
  }

  _ErrorCopy? getCopy(BuildContext context) {
    final bool itDisabled = !choreographer.itEnabled;
    final bool igcDisabled = !choreographer.igcEnabled;
    final Room? room = Matrix.of(context).client.getRoomById(roomID!);

    final bool itDisabledByClass = choreographer
        .pangeaController.permissionsController
        .isToolDisabledByClass(ToolSetting.interactiveTranslator, room);
    final bool igcDisabledByClass = choreographer
        .pangeaController.permissionsController
        .isToolDisabledByClass(ToolSetting.interactiveGrammar, room);

    if (itDisabledByClass && igcDisabledByClass) {
      return _ErrorCopy(
        L10n.of(context)!.errorDisableLanguageAssistanceClassDesc,
      );
    }

    if (itDisabledByClass) {
      if (igcDisabled) {
        return _ErrorCopy(
          "{L10n.of(context)!.errorDisableITClassDesc} ${L10n.of(context)!.errorDisableIGC}",
          " ${L10n.of(context)!.errorDisableIGCUserDesc}",
        );
      } else {
        return _ErrorCopy(L10n.of(context)!.errorDisableITClassDesc);
      }
    }

    if (igcDisabledByClass) {
      if (itDisabled) {
        return _ErrorCopy(
          "${L10n.of(context)!.errorDisableIGCClassDesc} ${L10n.of(context)!.errorDisableIT}",
          " ${L10n.of(context)!.errorDisableITUserDesc}",
        );
      } else {
        return _ErrorCopy(L10n.of(context)!.errorDisableIGCClassDesc);
      }
    }

    if (igcDisabled && itDisabled) {
      return _ErrorCopy(
        L10n.of(context)!.errorDisableLanguageAssistance,
        " ${L10n.of(context)!.errorDisableLanguageAssistanceUserDesc}",
      );
    }

    if (itDisabled) {
      return _ErrorCopy(
        L10n.of(context)!.errorDisableIT,
        " ${L10n.of(context)!.errorDisableITUserDesc}",
      );
    }

    if (igcDisabled) {
      return _ErrorCopy(
        L10n.of(context)!.errorDisableIGC,
        " ${L10n.of(context)!.errorDisableIGCUserDesc}",
      );
    }

    debugger(when: kDebugMode);
    ErrorHandler.logError(
      e: Exception("Unhandled case in language permissions"),
    );
    return null;
  }

  void showMessage(BuildContext context, Widget text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: text,
      ),
    );
  }
}
