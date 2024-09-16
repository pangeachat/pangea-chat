// class for
// 1) choosing constructs to do practice activities with
// 2) fetching said activities
// 3) maybe here - saving activities as activity events
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/practice_activities.dart/practice_activity_model.dart';
import 'package:fluffychat/pangea/widgets/chat/message_selection_overlay.dart';

class MessageActivityController {
  final MessageSelectionOverlay controller;

  final PangeaController pangeaController;
  final PangeaMessageEvent pangeaMessageEvent;

  final List<ConstructIdentifier> targetConstructs = [];

  MessageActivityController({
    required this.controller,
    required this.pangeaController,
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
  }
}
