import 'dart:developer';

import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/enum/construct_type_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_representation_event.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/practice_activity_event.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/message_activity_request.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/practice_activity_model.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/practice_activity_record_model.dart';
import 'package:fluffychat/pangea/utils/bot_style.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/pangea/widgets/chat/message_selection_overlay.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/practice_activity_content.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

/// The wrapper for practice activity content.
/// Handles the activities associated with a message,
/// their navigation, and the management of completion records
class PracticeActivityCard extends StatefulWidget {
  final PangeaMessageEvent pangeaMessageEvent;
  final MessageOverlayController overlayController;

  const PracticeActivityCard({
    super.key,
    required this.pangeaMessageEvent,
    required this.overlayController,
  });

  @override
  MessagePracticeActivityCardState createState() =>
      MessagePracticeActivityCardState();
}

class MessagePracticeActivityCardState extends State<PracticeActivityCard> {
  PracticeActivityEvent? currentActivity;
  PracticeActivityRecordModel? currentRecordModel;
  bool sending = false;

  List<PracticeActivityEvent> get practiceActivities =>
      widget.pangeaMessageEvent.practiceActivities;

  int get practiceEventIndex => practiceActivities.indexWhere(
        (activity) => activity.event.eventId == currentActivity?.event.eventId,
      );

  bool get isPrevEnabled =>
      false &&
      practiceEventIndex > 0 &&
      practiceActivities.length > (practiceEventIndex - 1);

  bool get isNextEnabled =>
      false &&
      practiceEventIndex >= 0 &&
      practiceEventIndex < practiceActivities.length - 1;

  @override
  void initState() {
    super.initState();
    getActivity();
  }

  Future<void> getActivity() async {
    /// Initalizes the current activity.
    /// If the current activity hasn't been set yet, show the first
    /// uncompleted activity if there is one.
    /// If not, show the first activity

    final List<PracticeActivityEvent> incompleteActivities =
        practiceActivities.where((element) => !element.isComplete).toList();

    currentActivity ??=
        incompleteActivities.isNotEmpty ? incompleteActivities.first : null;

    // TODO - make sure activity is targeting the words we want it to target
    if (currentActivity != null) {
      debugPrint(
        "Activity already exists for this message",
      );
      debugger(when: kDebugMode);

      await setSelectedTokenIndicesBasedOnActivity();

      widget.overlayController.setState(() {});
      return;
    }

    final List<TokenWithXP> tokensToTarget = await getTargetTokens(context);

    if (tokensToTarget.isEmpty) {
      debugger(when: kDebugMode);
      return;
    }

    if (!pangeaController.languageController.languagesSet) {
      debugger(when: kDebugMode);
      return;
    }

    currentActivity =
        await pangeaController.practiceGenerationController.getPracticeActivity(
      MessageActivityRequest(
        userL1: pangeaController.languageController.userL1!.langCode,
        userL2: pangeaController.languageController.userL2!.langCode,
        messageText: representation!.text,
        tokensWithXP: tokensToTarget,
        messageId: widget.pangeaMessageEvent.eventId,
      ),
      widget.pangeaMessageEvent,
    );

    await setSelectedTokenIndicesBasedOnActivity();

    widget.overlayController.setState(() {});
  }

  Future<void> setSelectedTokenIndicesBasedOnActivity() async {
    final messageTokens = await representation!.tokensGlobal(context);

    if (messageTokens == null) {
      widget.overlayController.setState(() {});
      debugger(when: kDebugMode);
      return;
    }

    final List<int> targetTokens =
        currentActivity!.practiceActivity.tgtConstructs
            .map(
              (e) => messageTokens
                  .indexWhere((element) => element.lemma.text == e.lemma),
            )
            .toList();

    if (targetTokens.isNotEmpty) {
      widget.overlayController.selectedTokenIndicies.clear();
      widget.overlayController.selectedTokenIndicies.addAll(targetTokens);
    } else {
      debugger(when: kDebugMode);
    }
  }

  RepresentationEvent? get representation =>
      widget.pangeaMessageEvent.originalSent;

  String get messsageText => representation!.text;

  PangeaController get pangeaController => MatrixState.pangeaController;

  Future<List<TokenWithXP>> getTargetTokens(BuildContext context) async {
    // fetch constructs for message
    // find constructs with lowest XP
    // set target constructs to those
    // fetch activities for those constructs

    // get the latest value for the user's construct uses
    // and turn it into a ConstructListModel

    final constructUses =
        MatrixState.pangeaController.analytics.analyticsStream.value;

    debugger(when: kDebugMode && constructUses == null);

    //Question - what do we do in the case of constructs being empty?
    final constructs = ConstructListModel(
      uses: constructUses ?? [],
      type: null,
    ).constructs;

    // get the constructs that are used in this message
    if (representation == null) {
      debugger(when: kDebugMode);
      return [];
    }

    final tokens = await representation!.tokensGlobal(context);

    if (tokens == null) {
      debugger(when: kDebugMode);
      return [];
    }

    final List<TokenWithXP> tokenCounts = [];

    // TODO - add morph constructs to this list as well
    for (int i = 0; i < tokens.length; i++) {
      //don't bother with tokens that we don't save to vocab
      if (!tokens[i].lemma.saveVocab) {
        continue;
      }
      final token = tokens[i];
      final constructsWithXp = <ConstructWithXP>[];

      for (final construct in constructs) {
        if (construct.lemma == token.lemma.text) {
          constructsWithXp.add(
            ConstructWithXP(
              construct: ConstructIdentifier(
                lemma: token.lemma.text,
                type: ConstructTypeEnum.vocab,
              ),
              xp: construct.uses.length,
              lastUsed: construct.lastUsed,
            ),
          );
        }
      }

      tokenCounts.add(
        TokenWithXP(
          token: token,
          constructs: constructsWithXp,
        ),
      );
    }

    tokenCounts.sort((a, b) => a.xp.compareTo(b.xp));

    return tokenCounts;
  }

  void setCurrentModel(PracticeActivityRecordModel? recordModel) {
    currentRecordModel = recordModel;
  }

  /// Sets the current acitivity based on the given [direction].
  void navigateActivities(Direction direction) {
    final bool enableNavigation = (direction == Direction.f && isNextEnabled) ||
        (direction == Direction.b && isPrevEnabled);
    if (enableNavigation) {
      currentActivity = practiceActivities[direction == Direction.f
          ? practiceEventIndex + 1
          : practiceEventIndex - 1];
      setState(() {});
    }
  }

  /// Sends the current record model and activity to the server.
  /// If either the currentRecordModel or currentActivity is null, the method returns early.
  /// Sets the [sending] flag to true before sending the record and activity.
  /// Logs any errors that occur during the send operation.
  /// Sets the [sending] flag to false when the send operation is complete.
  void sendRecord() {
    print("Sending record");
    if (currentRecordModel == null || currentActivity == null) return;
    setState(() => sending = true);
    MatrixState.pangeaController.activityRecordController
        .send(currentRecordModel!, currentActivity!)
        .catchError((error) {
      debugger(when: kDebugMode);
      ErrorHandler.logError(
        e: error,
        s: StackTrace.current,
        data: {
          'recordModel': currentRecordModel?.toJson(),
          'practiceEvent': currentActivity?.event.toJson(),
        },
      );
      return null;
    }).then((event) {
      // The record event is processed into construct uses for learning analytics, so if the
      // event went through without error, send it to analytics to be processed
      if (event != null && currentActivity != null) {
        MatrixState.pangeaController.myAnalytics.setState(
          data: {
            'eventID': widget.pangeaMessageEvent.eventId,
            'eventType': PangeaEventTypes.activityRecord,
            'roomID': event.room.id,
            'practiceActivity': currentActivity!,
            'recordModel': currentRecordModel!,
          },
        );
      }
    }).whenComplete(
      () => setState(() {
        sending = false;
        getActivity();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final Widget navigationButtons = Row(
    //   mainAxisSize: MainAxisSize.max,
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Opacity(
    //       opacity: isPrevEnabled ? 1.0 : 0,
    //       child: IconButton(
    //         onPressed:
    //             isPrevEnabled ? () => navigateActivities(Direction.b) : null,
    //         icon: const Icon(Icons.keyboard_arrow_left_outlined),
    //         tooltip: L10n.of(context)!.previous,
    //       ),
    //     ),
    //     Expanded(
    //       child: Opacity(
    //         opacity: currentActivity?.userRecord == null ? 1.0 : 0.5,
    //         child: sending
    //             ? const CircularProgressIndicator.adaptive()
    //             : TextButton(
    //                 onPressed:
    //                     currentActivity?.userRecord == null ? sendRecord : null,
    //                 style: ButtonStyle(
    //                   backgroundColor: WidgetStateProperty.all<Color>(
    //                     AppConfig.primaryColor,
    //                   ),
    //                 ),
    //                 child: Text(L10n.of(context)!.submit),
    //               ),
    //       ),
    //     ),
    //     Opacity(
    //       opacity: isNextEnabled ? 1.0 : 0,
    //       child: IconButton(
    //         onPressed:
    //             isNextEnabled ? () => navigateActivities(Direction.f) : null,
    //         icon: const Icon(Icons.keyboard_arrow_right_outlined),
    //         tooltip: L10n.of(context)!.next,
    //       ),
    //     ),
    //   ],
    // );

    if (currentActivity == null || practiceActivities.isEmpty) {
      return Text(
        L10n.of(context)!.noActivitiesFound,
        style: BotStyle.text(context),
      );
      // return GeneratePracticeActivityButton(
      //   pangeaMessageEvent: widget.pangeaMessageEvent,
      //   onActivityGenerated: updatePracticeActivity,
      // );
    }
    return Column(
      children: [
        PracticeActivity(
          practiceEvent: currentActivity!,
          controller: this,
        ),
        // navigationButtons,
      ],
    );
  }
}
