import 'dart:async';

import 'package:fluffychat/pangea/constants/pangea_event_types.dart';
import 'package:fluffychat/pangea/controllers/base_controller.dart';
import 'package:fluffychat/pangea/controllers/pangea_controller.dart';
import 'package:matrix/matrix.dart';

// This is a controller for the story game. It's a way of maintaining states that need to
// be maintained across the app, even when the chat page is closed.
class StoryGameController extends BaseController {
  late PangeaController _pangeaController;
  StreamSubscription? _gameStateSubscription;

  StoryGameController(PangeaController pangeaController) {
    _pangeaController = pangeaController;
  }

  void initialize() {
    _gameStateSubscription = client.onRoomState.stream
        .where(isRoundUpdate)
        .listen(onGameStateUpdate);
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    _gameStateSubscription = null;
    super.dispose();
  }

  Client get client => _pangeaController.matrixState.client;

  bool isRoundUpdate(update) {
    return update.state is Event &&
        (update.state as Event).type == PangeaEventTypes.storyGame;
  }

  void onGameStateUpdate(update) {
    // TODO implement and test this

    // If the winner just got calculated, add XP points
    // for users who voted for / sent the winning message

    // One use for each of that message's lemmas and morphs.
    // The use type is ConstructUseTypeEnum.ss.
  }
}
