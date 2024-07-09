import 'package:fluffychat/pangea/enum/construct_type_enum.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_event.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';

/// A wrapper around a list of [ConstructAnalyticsEvent]s, used to simplify
/// the process of filtering / sorting / displaying the events.
/// Takes a construct type and a list of events
class ConstructListModel {
  ConstructTypeEnum type;
  List<ConstructAnalyticsEvent> constructEvents;

  ConstructListModel({
    required this.type,
    required this.constructEvents,
  });

  /// All unique lemmas used in the construct events
  List<String> get lemmas => constructs.map((e) => e.lemma).toSet().toList();

  /// A list of ConstructUses, each of which contains a lemma and
  /// a list of uses, sorted by the number of uses
  List<ConstructUses> get constructs => constructsFromUses(uses);

  /// A list of all uses of the construct type
  List<OneConstructUse> get uses => constructEvents
      .map((event) => event.content.uses)
      .expand((uses) => uses)
      .cast<OneConstructUse>()
      .where((use) => use.constructType == type)
      .toList();

  /// Takes a list of uses and sorts them into a list of ConstructUses
  List<ConstructUses> constructsFromUses(List<OneConstructUse> uses) {
    final Map<String, List<OneConstructUse>> lemmaToUses = {};
    for (final use in uses) {
      if (use.lemma == null) continue;
      lemmaToUses[use.lemma!] ??= [];
      lemmaToUses[use.lemma!]!.add(use);
    }

    final constructUses = lemmaToUses.entries
        .map(
          (entry) => ConstructUses(
            lemma: entry.key,
            uses: entry.value,
            constructType: type,
          ),
        )
        .toList();

    constructUses.sort((a, b) {
      final comp = b.uses.length.compareTo(a.uses.length);
      if (comp != 0) return comp;
      return a.lemma.compareTo(b.lemma);
    });

    return constructUses;
  }

  // setting this up for accept multiple kinds of filters
  // in the future, but for now, only need to filter by eventID

  /// Given a filter, returns a list of ConstructUses that match the filter
  List<ConstructUses> filteredUses({String? eventID}) {
    final List<OneConstructUse> filtered =
        uses.where((use) => use.msgId == eventID).toList();
    return constructsFromUses(filtered);
  }
}
