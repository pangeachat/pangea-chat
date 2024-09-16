// class for
// 1) choosing constructs to do practice activities with
// 2) fetching said activities
// 3) maybe here - saving activities as activity events
import 'package:fluffychat/pangea/enum/construct_type_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/practice_activity_model.dart';
import 'package:fluffychat/pangea/widgets/chat/message_selection_overlay.dart';
import 'package:fluffychat/widgets/matrix.dart';

class MessageActivityController {
  final MessageSelectionOverlayState controller;
  final PangeaMessageEvent pangeaMessageEvent;

  final List<ConstructIdentifier> targetConstructs = [];

  MessageActivityController({
    required this.controller,
    required this.pangeaMessageEvent,
  });

  // fetch constructs for message
  // find constructs with lowest XP
  // set target constructs to those
  // fetch activities for those constructs

  void fetchConstructs() {
    // fetch constructs for message
    // find constructs with lowest XP
    // set target constructs to those
    // fetch activities for those constructs

    // get the latest value for the user's construct uses
    // and turn it into a ConstructListModel
    final constructs =
        MatrixState.pangeaController.myAnalytics.analyticsUpdateStream.value;

    final constructModel = ConstructListModel(
      uses: constructs,
      type: ConstructTypeEnum.vocab,
    );

    // get the constructs that are used in this message
    final msgConstructs = pangeaMessageEvent.allConstructUses.where(
      (use) => use.constructType == ConstructTypeEnum.vocab,
    );
  }
}
