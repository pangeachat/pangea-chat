import 'dart:developer';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/analytics/controllers/put_analytics_controller.dart';
import 'package:fluffychat/pangea/analytics/widgets/gain_points.dart';
import 'package:fluffychat/pangea/common/utils/error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/matrix.dart';
import '../../../bot/widgets/bot_face_svg.dart';
import '../../../common/controllers/pangea_controller.dart';
import 'card_header.dart';

class SubmitChallengeAskCardModel {
  void Function()? onReject;
  void Function()? onAccept;

  SubmitChallengeAskCardModel({
    this.onReject,
    this.onAccept,
  });
}

class SubmitChallengeAskCard extends StatefulWidget {
  final PangeaController pangeaController = MatrixState.pangeaController;
  final SubmitChallengeAskCardModel m;
  final String roomId;

  SubmitChallengeAskCard({
    super.key,
    required this.m,
    required this.roomId,
  });

  @override
  State<SubmitChallengeAskCard> createState() => SubmitChallengeAskCardState();
}

class SubmitChallengeAskCardState extends State<SubmitChallengeAskCard> {
  Object? error;
  bool fetchingData = false;
  int? selectedChoiceIndex;

  BotExpression currentExpression = BotExpression.nonGold;

  @override
  void initState() {
    // debugger(when: kDebugMode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned(
            top: 40,
            child: PointsGainedAnimation(
              origin: AnalyticsUpdateOrigin.igc,
            ),
          ),
          Column(
            children: [
              const CardHeader(
                text:
                    "That was a tough message! Want to submit it to the Space as a challenge for others?",
                botExpression: BotExpression.surprised,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Opacity(
                      opacity: 0.8,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            AppConfig.primaryColor.withAlpha(25),
                          ),
                        ),
                        onPressed: () {
                          MatrixState.pAnyState.closeOverlay();
                          widget.m.onReject?.call();
                        },
                        child: const Center(
                          child: Text("Nah"),
                          // child: Text(L10n.of(context).ignoreInThisText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Opacity(
                      opacity: 1.0,
                      child: TextButton(
                        onPressed: () {
                          MatrixState.pAnyState.closeOverlay();
                          widget.m.onAccept?.call();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            AppConfig.primaryColor.withAlpha(50),
                          ),
                        ),
                        child: const Text("Sure, submit it!"),
                        // child: Text(L10n.of(context).replace),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ],
      );
    } on Exception catch (e) {
      debugger(when: kDebugMode);
      ErrorHandler.logError(
        e: e,
        s: StackTrace.current,
        data: {},
      );
      rethrow;
    }
  }
}
