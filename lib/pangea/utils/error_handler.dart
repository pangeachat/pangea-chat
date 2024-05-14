import 'dart:async';

import 'package:fluffychat/pangea/config/environment.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorHandler {
  ErrorHandler();

  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = Environment.sentryDsn;
        options.tracesSampleRate = 0.1;
        options.debug = kDebugMode;
        options.environment = kDebugMode
            ? "debug"
            : Environment.isStaging
                ? "staging"
                : "productionC";
      },
    );

    // Error handling
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (!kDebugMode || PlatformInfos.isMobile) {
        Sentry.captureException(
          details.exception,
          stackTrace: details.stack ?? StackTrace.current,
        );
      }
    };

    PlatformDispatcher.instance.onError = (exception, stack) {
      logError(e: exception, s: stack);
      return true;
    };
  }

  static logError({
    Object? e,
    StackTrace? s,
    String? m,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.error,
  }) async {
    if (m != null) debugPrint("error message: $m");
    if ((e ?? m) != null) debugPrint("error to string: ${e?.toString() ?? m}");
    if (data != null) {
      Sentry.addBreadcrumb(Breadcrumb.fromJson(data));
      debugPrint(data.toString());
    }

    Sentry.captureException(
      e ?? Exception(m ?? "no message supplied"),
      stackTrace: s ?? StackTrace.current,
      withScope: (scope) {
        scope.level = level;
      },
    );
  }
}

class ErrorCopy {
  BuildContext context;
  Object? error;

  late String title;
  late String body;
  int? errorCode;

  ErrorCopy(this.context, this.error) {
    setCopy();
  }

  void _setDefaults() {
    title = "Unexpected error.";
    body = "Please reload and try again.";
    errorCode = 400;
  }

  void setCopy() {
    try {
      if (error is http.Response) {
        errorCode = (error as http.Response).statusCode;
      } else {
        ErrorHandler.logError(e: error, s: StackTrace.current);
        errorCode = null;
      }
      if (L10n.of(context) == null) {
        _setDefaults();
        Sentry.addBreadcrumb(Breadcrumb.fromJson({"error": error?.toString()}));
        ErrorHandler.logError(
          m: "null L10n in ErrorCopy.setCopy",
          s: StackTrace.current,
        );
        return;
      }
      final L10n l10n = L10n.of(context)!;

      switch (errorCode) {
        case 502:
        case 504:
        case 500:
          title = l10n.error502504Title;
          body = l10n.error502504Desc;
          break;
        case 404:
          title = l10n.error404Title;
          body = l10n.error404Desc;
          break;
        case 405:
          title = l10n.error405Title;
          body = l10n.error405Desc;
          break;
        case 601:
          title = l10n.errorDisableIT;
          body = l10n.errorDisableITUserDesc;
          break;
        case 602:
          title = l10n.errorDisableIGC;
          body = l10n.errorDisableIGCUserDesc;
          break;
        case 603:
          title = l10n.errorDisableIT;
          body = l10n.errorDisableITClassDesc;
          break;
        case 604:
          title = l10n.errorDisableIGC;
          body = l10n.errorDisableIGCClassDesc;
          break;
        default:
          title = l10n.oopsSomethingWentWrong;
          body = l10n.errorPleaseRefresh;
      }
    } catch (e, s) {
      ErrorHandler.logError(e: s, s: s);
      _setDefaults();
    }
  }
}
