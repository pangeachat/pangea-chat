import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/enum/bar_chart_view_enum.dart';
import 'package:fluffychat/pangea/enum/construct_type_enum.dart';
import 'package:fluffychat/pangea/enum/time_span.dart';
import 'package:fluffychat/pangea/enum/use_type.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/pages/analytics/base_analytics.dart';
import 'package:fluffychat/pangea/utils/bot_style.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/pangea/widgets/chat/toolbar_content_loading_indicator.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class MessageAnalyticsCard extends StatefulWidget {
  final PangeaMessageEvent messageEvent;

  const MessageAnalyticsCard({
    super.key,
    required this.messageEvent,
  });

  @override
  MessageAnalyticsCardState createState() => MessageAnalyticsCardState();
}

class MessageAnalyticsCardState extends State<MessageAnalyticsCard> {
  final PangeaController pangeaController = MatrixState.pangeaController;
  ConstructListModel? errorAnalyticsModel;
  ConstructListModel? vocabAnalyticsModel;
  BarChartViewSelection currentView = BarChartViewSelection.vocab;

  String get eventId => widget.messageEvent.eventId;
  List<ConstructUses>? get errorUses =>
      errorAnalyticsModel?.filteredUses(eventID: eventId);
  List<ConstructUses>? get vocabUses =>
      vocabAnalyticsModel?.filteredUses(eventID: eventId);
  List<ConstructUses>? get currentViewData =>
      currentView == BarChartViewSelection.vocab ? vocabUses : errorUses;

  bool fetching = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => fetching = true);
    try {
      final TimeSpan? since = TimeSpan.values.firstWhereOrNull(
        (span) => span.cutOffDate.isBefore(widget.messageEvent.originServerTs),
      );
      await Future.wait(
        [
          loadGrammarAnalytics(since: since),
          loadVocabAnalytics(since: since),
        ],
      );
      errorAnalyticsModel?.filteredUses(eventID: eventId);
      vocabAnalyticsModel?.filteredUses(eventID: eventId);
    } catch (err, s) {
      ErrorHandler.logError(
        e: err,
        s: s,
        m: "Error loading analytics for message ${widget.messageEvent.eventId}",
      );
    } finally {
      setState(() => fetching = false);
    }
  }

  Future<ConstructListModel?> loadConstructs({
    required ConstructTypeEnum type,
    TimeSpan? since,
  }) async {
    final errorEvents = await pangeaController.analytics.getConstructsById(
      constructType: type,
      id: widget.messageEvent.room.id,
      type: AnalyticsEntryType.room,
      timeSpan: since,
      // how to get the lang?
      // try to get the message's language code... it's not always true that messages
      // originalSent langCode will match up this the analytics room its sent to.
      // Don't show it in this case?
      lang: pangeaController.languageController.userL2,
    );
    if (errorEvents != null && errorEvents.isNotEmpty) {
      return ConstructListModel(
        type: type,
        constructEvents: errorEvents,
      );
    }
    return null;
  }

  // I'm putting the loading of grammar and vocab constructs into
  // separate methods to make it easier to run them in parallel
  Future<void> loadGrammarAnalytics({TimeSpan? since}) async =>
      errorAnalyticsModel = await loadConstructs(
        type: ConstructTypeEnum.grammar,
        since: since,
      );

  Future<void> loadVocabAnalytics({TimeSpan? since}) async =>
      vocabAnalyticsModel = await loadConstructs(
        type: ConstructTypeEnum.vocab,
        since: since,
      );

  void setCurrentView(BarChartViewSelection view) {
    currentView = view;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (fetching) {
      return const ToolbarContentLoadingIndicator();
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 0, maxHeight: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                icon: Icon(BarChartViewSelection.grammar.icon),
                onPressed: () => setCurrentView(BarChartViewSelection.grammar),
                color: UseType.wa.color(context),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withOpacity(
                        currentView == BarChartViewSelection.grammar ? 1 : 0.25,
                      ),
                ),
                padding: const EdgeInsets.all(0),
                iconSize: 20,
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                icon: Icon(BarChartViewSelection.vocab.icon),
                onPressed: () => setCurrentView(BarChartViewSelection.vocab),
                color: UseType.ga.color(context),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withOpacity(
                        currentView == BarChartViewSelection.vocab ? 1 : 0.25,
                      ),
                ),
                padding: const EdgeInsets.all(0),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          (currentViewData == null || currentViewData!.isEmpty)
              ? Center(
                  child: Text(
                    L10n.of(context)!.noDataFound,
                    style: BotStyle.text(context),
                  ),
                )
              : Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: currentViewData
                              ?.map((use) => Text(use.lemma))
                              .toList() ??
                          [const CircularProgressIndicator.adaptive()],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
