import 'dart:developer';

import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/controllers/my_analytics_controller.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/enum/activity_type_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_representation_event.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/practice_activity_event.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/message_activity_request.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/practice_activity_model.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/practice_activity_record_model.dart';
import 'package:fluffychat/pangea/utils/bot_style.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/pangea/widgets/chat/message_selection_overlay.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/multiple_choice_activity.dart';
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
  PracticeActivityRecordModel? currentCompletionRecord;
  bool fetchingActivity = true;

  final List<TokenWithXP> targetTokens = [];

  List<PracticeActivityEvent> get practiceActivities =>
      widget.pangeaMessageEvent.practiceActivities;

  int get practiceEventIndex => practiceActivities.indexWhere(
        (activity) => activity.event.eventId == currentActivity?.event.eventId,
      );

  @override
  void initState() {
    super.initState();
    getActivity();
  }

  void updateFetchingActivity(bool value) {
    if (fetchingActivity == value) return;
    widget.overlayController.setState(() => fetchingActivity = value);
  }

  Future<void> getActivity([bool forceNew = false]) async {
    /// Initalizes the current activity.
    /// If the current activity hasn't been set yet, show the first
    /// uncompleted activity if there is one.
    /// If not, show the first activity

    debugger(when: kDebugMode && forceNew);

    updateFetchingActivity(true);

    final List<PracticeActivityEvent> incompleteActivities =
        practiceActivities.where((element) => !element.isComplete).toList();

    final PracticeActivityEvent? existingActivity =
        incompleteActivities.isNotEmpty ? incompleteActivities.first : null;

    if (existingActivity != null &&
        existingActivity.practiceActivity !=
            currentActivity?.practiceActivity) {
      currentActivity = existingActivity;
    }

    // TODO - make sure activity is targeting the words we want it to target
    if (currentActivity != null && !forceNew) {
      debugPrint(
        "Activity already exists for this message",
      );
      // debugger(when: kDebugMode);

      await setSelectedTokenIndicesBasedOnActivity();

      updateFetchingActivity(false);
      return;
    }

    await setTargetTokens(context);

    if (targetTokens.isEmpty ||
        !pangeaController.languageController.languagesSet) {
      debugger(when: kDebugMode);
      widget.overlayController.exitPracticeFlow();
      return;
    }

    currentActivity =
        await pangeaController.practiceGenerationController.getPracticeActivity(
      MessageActivityRequest(
        userL1: pangeaController.languageController.userL1!.langCode,
        userL2: pangeaController.languageController.userL2!.langCode,
        messageText: representation!.text,
        tokensWithXP: targetTokens,
        messageId: widget.pangeaMessageEvent.eventId,
      ),
      widget.pangeaMessageEvent,
    );

    // we want to highlight the target tokens in the message
    // so we add these to the overlay controller
    await setSelectedTokenIndicesBasedOnActivity();

    /// Removes the target tokens of the new activity from the target tokens list.
    /// This avoids getting activities for the same token again, at least
    /// until the user exists the toolbar and re-enters it. By then, the
    /// analytics stream will have updated and the user will be able to get
    /// activity data for previously targeted tokens. This should then exclude
    /// the tokens that were targeted in previous activities based on xp and lastUsed.
    if (currentActivity?.practiceActivity.relevantSpanDisplayDetails != null) {
      targetTokens.removeWhere((token) {
        final RelevantSpanDisplayDetails span =
            currentActivity!.practiceActivity.relevantSpanDisplayDetails!;
        return token.token.text.offset >= span.offset &&
            token.token.text.offset + token.token.text.length <=
                span.offset + span.length;
      });
    }

    updateFetchingActivity(false);
  }

  Future<void> setSelectedTokenIndicesBasedOnActivity() async {
    final RelevantSpanDisplayDetails? span =
        currentActivity?.practiceActivity.multipleChoice?.spanDisplayDetails;

    if (span == null) {
      debugger(when: kDebugMode);
      return;
    }

    final messageTokens = await representation!.tokensGlobal(context);

    if (messageTokens == null) {
      updateFetchingActivity(false);
      debugger(when: kDebugMode);
      return;
    }

    final List<int> targetTokensIndices =
        indicesOfTargetTokens(messageTokens, span);

    if (targetTokensIndices.isNotEmpty) {
      widget.overlayController.selectedTokenIndicies.clear();
      widget.overlayController.selectedTokenIndicies
          .addAll(targetTokensIndices);
    } else {
      debugger(when: kDebugMode);
    }
  }

  List<int> indicesOfTargetTokens(
    List<PangeaToken>? messageTokens,
    RelevantSpanDisplayDetails? span,
  ) {
    if (messageTokens == null || span == null) {
      debugger(when: kDebugMode);
      return [];
    }
    final List<int> targetTokensIndices = [];
    for (int i = 0; i < messageTokens.length; i++) {
      final token = messageTokens[i];
      if (token.text.offset >= span.offset &&
          token.text.offset + token.text.length <= span.offset + span.length) {
        targetTokensIndices.add(i);
      }
    }
    return targetTokensIndices;
  }

  RepresentationEvent? get representation =>
      widget.pangeaMessageEvent.originalSent;

  String get messsageText => representation!.text;

  PangeaController get pangeaController => MatrixState.pangeaController;

  Future<void> setTargetTokens(BuildContext context) async {
    final tokens = await representation?.tokensGlobal(context);
    if (tokens == null || tokens.isEmpty) {
      debugger(when: kDebugMode);
      return;
    }

    final constructUses =
        MatrixState.pangeaController.analytics.analyticsStream.value;

    if (constructUses == null) {
      debugger(when: kDebugMode);
      return;
    }

    final ConstructListModel constructList = ConstructListModel(
      uses: constructUses,
      type: null,
    );

    final List<TokenWithXP> tokenCounts = [];

    // TODO - add morph constructs to this list as well
    for (int i = 0; i < tokens.length; i++) {
      //don't bother with tokens that we don't save to vocab
      if (!tokens[i].lemma.saveVocab) {
        continue;
      }

      tokenCounts.add(tokens[i].emptyTokenWithXP);

      for (final construct in tokenCounts.last.constructs) {
        final constructUseModel = constructList.getConstructUses(
          construct.id.lemma,
          construct.id.type,
        );
        if (constructUseModel != null) {
          construct.xp = constructUseModel.points;
        }
      }
    }

    // debugger(when: kDebugMode);

    tokenCounts.sort((a, b) => a.xp.compareTo(b.xp));

    debugger(when: kDebugMode && tokenCounts.isEmpty);

    targetTokens.addAll(tokenCounts);

    return;
  }

  void setCompletionRecord(PracticeActivityRecordModel? recordModel) {
    currentCompletionRecord = recordModel;
  }

  /// Sends the current record model and activity to the server.
  /// If either the currentRecordModel or currentActivity is null, the method returns early.
  /// Sets the [sending] flag to true before sending the record and activity.
  /// Logs any errors that occur during the send operation.
  /// Sets the [sending] flag to false when the send operation is complete.
  /// previously was called sendRecord
  void processCorrectAnswer() async {
    try {
      setState(() => fetchingActivity = true);

      if (currentCompletionRecord == null || currentActivity == null) {
        debugger(when: kDebugMode);
        return;
      }

      //TODO - @ggurdin figure out how to not await this but still give user their XP immediately
      final Event? event = await MatrixState
          .pangeaController.activityRecordController
          .send(currentCompletionRecord!, currentActivity!);

      MatrixState.pangeaController.myAnalytics.setState(
        AnalyticsStream(
          eventId: widget.pangeaMessageEvent.eventId,
          eventType: PangeaEventTypes.activityRecord,
          roomId: event!.room.id,
          practiceActivity: currentActivity!,
          recordModel: currentCompletionRecord!,
        ),
      );
    } catch (e, s) {
      debugger(when: kDebugMode);
      ErrorHandler.logError(
        e: e,
        s: s,
        m: 'Failed to send record for activity',
        data: {
          'activity': currentActivity,
          'record': currentCompletionRecord,
        },
      );
    } finally {
      getActivity(true);
    }
  }

  Widget get activityWidget {
    if (currentActivity == null) {
      // return sizedbox with height of 80
      return const SizedBox(height: 80);
    }
    switch (currentActivity!.practiceActivity.activityType) {
      case ActivityTypeEnum.multipleChoice:
        return MultipleChoiceActivity(
          practiceCardController: this,
          currentActivity: currentActivity,
        );
      default:
        ErrorHandler.logError(
          e: Exception('Unknown activity type'),
          m: 'Unknown activity type',
          data: {
            'activityType': currentActivity!.practiceActivity.activityType,
          },
        );
        return Text(
          L10n.of(context)!.oopsSomethingWentWrong,
          style: BotStyle.text(context),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!fetchingActivity && currentActivity == null) {
      return Text(
        L10n.of(context)!.noActivitiesFound,
        style: BotStyle.text(context),
      );
    }

    return Stack(
      children: [
        // Main content
        Column(
          children: [
            activityWidget,
            // navigationButtons,
          ],
        ),
        // Conditionally show the darkening and progress indicator based on the loading state
        if (fetchingActivity) ...[
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5), // Darkening effect
          ),
          // Circular progress indicator in the center
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }
}
