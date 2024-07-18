import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/enum/construct_type_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_representation_event.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/models/pangea_match_model.dart';
import 'package:fluffychat/pangea/pages/analytics/base_analytics.dart';
import 'package:fluffychat/pangea/pages/analytics/construct_message.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class ConstructList extends StatefulWidget {
  final ConstructTypeEnum constructType;
  final String id;
  final AnalyticsEntryType type;
  final PangeaController pangeaController;

  const ConstructList({
    super.key,
    required this.id,
    required this.type,
    required this.constructType,
    required this.pangeaController,
  });

  @override
  State<StatefulWidget> createState() => ConstructListState();
}

class ConstructListState extends State<ConstructList> {
  String? langCode;
  String? error;

  @override
  Widget build(BuildContext context) {
    return error != null
        ? Center(
            child: Text(error!),
          )
        : Column(
            children: [
              ConstructListView(
                id: widget.id,
                type: widget.type,
                constructType: widget.constructType,
                pangeaController: widget.pangeaController,
              ),
            ],
          );
  }
}

// list view of construct events
// parameters
//  1) a list of construct events and
//  2) a boolean indicating whether the list has been initialized
// if not initialized, show loading indicator
// for each tile,
//    title = construct.content.lemma
//    subtitle = total uses, equal to construct.content.uses.length
// list has a fixed height of 400 and is scrollable
class ConstructListView extends StatefulWidget {
  final String id;
  final AnalyticsEntryType type;
  final ConstructTypeEnum constructType;
  final PangeaController pangeaController;

  const ConstructListView({
    super.key,
    required this.id,
    required this.type,
    required this.constructType,
    required this.pangeaController,
  });

  @override
  State<StatefulWidget> createState() => ConstructListViewState();
}

class ConstructListViewState extends State<ConstructListView> {
  final Map<String, Timeline> _timelinesCache = {};
  final Map<String, PangeaMessageEvent> _msgEventCache = {};
  final List<PangeaMessageEvent> _msgEvents = [];
  bool fetchingConstructs = true;
  bool fetchingUses = false;
  String? currentLemma;
  StreamSubscription? stateSub;
  ConstructListModel? constructsModel;

  @override
  void initState() {
    super.initState();
    updateConstructs();
    stateSub = widget.pangeaController.analytics.stateStream.listen((_) {
      updateConstructs();
    });
  }

  @override
  void didUpdateWidget(covariant ConstructListView oldWidget) {
    if (oldWidget.constructType != widget.constructType) {
      updateConstructs();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    stateSub?.cancel();
    super.dispose();
  }

  void updateConstructs() {
    setState(() => fetchingConstructs = true);
    // postframe callback to let widget rebuild with the new selected parameter
    // before sending selected to getConstructs function
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.pangeaController.analytics
          .getConstructsById(
        constructType: widget.constructType,
        id: widget.id,
        type: widget.type,
      )
          .then(
        (value) {
          if (mounted) {
            setState(() {
              constructsModel = ConstructListModel(
                type: widget.constructType,
                constructEvents: value ?? [],
              );
            });
          }
        },
      ).whenComplete(() {
        if (mounted) {
          setState(() => fetchingConstructs = false);
        }
      });
    });
  }

  int get lemmaIndex =>
      constructsModel?.constructs.indexWhere(
        (element) => element.lemma == currentLemma,
      ) ??
      -1;

  Future<PangeaMessageEvent?> getMessageEvent(
    OneConstructUse use,
  ) async {
    final Client client = Matrix.of(context).client;
    PangeaMessageEvent msgEvent;
    if (_msgEventCache.containsKey(use.msgId!)) {
      return _msgEventCache[use.msgId!]!;
    }
    final Room? msgRoom = use.getRoom(client);
    if (msgRoom == null || use.msgId == null) {
      return null;
    }

    Timeline? timeline;
    if (_timelinesCache.containsKey(use.chatId)) {
      timeline = _timelinesCache[use.chatId];
    } else {
      timeline = await msgRoom.getTimeline();
      _timelinesCache[use.chatId] = timeline;
    }

    final Event? event = await use.getEvent(client);
    if (event == null || timeline == null) {
      return null;
    }

    msgEvent = PangeaMessageEvent(
      event: event,
      timeline: timeline,
      ownMessage: event.senderId == client.userID,
    );
    _msgEventCache[use.msgId!] = msgEvent;
    return msgEvent;
  }

  Future<void> fetchUses() async {
    if (fetchingUses) return;
    if (currentConstruct == null) {
      setState(() => _msgEvents.clear());
      return;
    }

    setState(() => fetchingUses = true);
    try {
      final List<OneConstructUse> uses = currentConstruct!.uses;
      _msgEvents.clear();

      for (final OneConstructUse use in uses) {
        final PangeaMessageEvent? msgEvent = await getMessageEvent(use);
        final RepresentationEvent? repEvent =
            msgEvent?.originalSent ?? msgEvent?.originalWritten;
        if (repEvent?.choreo == null) {
          continue;
        }
        _msgEvents.add(msgEvent!);
      }
      setState(() => fetchingUses = false);
    } catch (err, s) {
      setState(() => fetchingUses = false);
      debugPrint("Error fetching uses: $err");
      ErrorHandler.logError(
        e: err,
        s: s,
        m: "Failed to fetch uses for current construct ${currentConstruct?.lemma}",
      );
    }
  }

  ConstructUses? get currentConstruct =>
      constructsModel?.constructs.firstWhereOrNull(
        (element) => element.lemma == currentLemma,
      );

  // given the current lemma and list of message events, return a list of
  // MessageEventMatch objects, which contain one PangeaMessageEvent to one PangeaMatch
  // this is because some message events may have has more than one PangeaMatch of a
  // given lemma type.
  List<MessageEventMatch> getMessageEventMatches() {
    if (currentLemma == null) return [];
    final List<MessageEventMatch> allMsgErrorSteps = [];

    for (final msgEvent in _msgEvents) {
      if (allMsgErrorSteps.any(
        (element) => element.msgEvent.eventId == msgEvent.eventId,
      )) {
        continue;
      }
      // get all the pangea matches in that message which have that lemma
      final List<PangeaMatch>? msgErrorSteps = msgEvent.errorSteps(
        currentLemma!,
      );
      if (msgErrorSteps == null) continue;

      allMsgErrorSteps.addAll(
        msgErrorSteps.map(
          (errorStep) => MessageEventMatch(
            msgEvent: msgEvent,
            lemmaMatch: errorStep,
          ),
        ),
      );
    }
    return allMsgErrorSteps;
  }

  Future<void> showConstructMessagesDialog() async {
    if (widget.constructType != ConstructTypeEnum.grammar) {
      return; // only show for grammar constructs
    }

    await showDialog<ConstructMessagesDialog>(
      context: context,
      builder: (c) => ConstructMessagesDialog(controller: this),
    );
  }

  void setCurrentLemma(String? lemma) {
    setState(() => currentLemma = lemma);
  }

  @override
  Widget build(BuildContext context) {
    if (fetchingConstructs || fetchingUses) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (constructsModel?.constructs.isEmpty ?? true) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Center(child: Text(L10n.of(context)!.noDataFound)),
      );
    }

    return Column(
      children: constructsModel!.constructs
          .map(
            (construct) => ListTile(
              title: Text(
                construct.lemma,
              ),
              subtitle: Text(
                '${L10n.of(context)!.total} ${construct.uses.length}',
              ),
              onTap: widget.constructType == ConstructTypeEnum.grammar
                  ? () async {
                      final String lemma = construct.lemma;
                      setCurrentLemma(lemma);
                      fetchUses().then((_) => showConstructMessagesDialog());
                    }
                  : null,
            ),
          )
          .toList(),
    );
  }
}

class ConstructMessagesDialog extends StatelessWidget {
  final ConstructListViewState controller;
  const ConstructMessagesDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.currentLemma == null ||
        controller.constructsModel == null ||
        controller.lemmaIndex < 0 ||
        controller.lemmaIndex >=
            controller.constructsModel!.constructs.length) {
      return const AlertDialog(content: CircularProgressIndicator.adaptive());
    }

    final msgEventMatches = controller.getMessageEventMatches();

    final noData = controller
            .constructsModel!.constructs[controller.lemmaIndex].uses.length >
        controller._msgEvents.length;

    return AlertDialog(
      title: Center(child: Text(controller.currentLemma!)),
      content: SizedBox(
        height: noData ? 90 : 250,
        width: noData ? 200 : 400,
        child: Column(
          children: [
            if (noData)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(L10n.of(context)!.roomDataMissing),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  ...msgEventMatches.mapIndexed(
                    (index, event) => Column(
                      children: [
                        ConstructMessage(
                          msgEvent: event.msgEvent,
                          lemma: controller.currentLemma!,
                          errorMessage: event.lemmaMatch,
                        ),
                        if (index < msgEventMatches.length - 1)
                          const Divider(height: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: false).pop(),
          child: Text(
            L10n.of(context)!.close.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class MessageEventMatch {
  final PangeaMessageEvent msgEvent;
  final PangeaMatch lemmaMatch;

  MessageEventMatch({
    required this.msgEvent,
    required this.lemmaMatch,
  });
}
