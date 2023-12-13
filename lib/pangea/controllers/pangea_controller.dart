import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:fluffychat/pangea/constants/class_default_values.dart';
import 'package:fluffychat/pangea/controllers/class_controller.dart';
import 'package:fluffychat/pangea/controllers/contextual_definition_controller.dart';
import 'package:fluffychat/pangea/controllers/language_controller.dart';
import 'package:fluffychat/pangea/controllers/language_list_controller.dart';
import 'package:fluffychat/pangea/controllers/local_settings.dart';
import 'package:fluffychat/pangea/controllers/message_data_controller.dart';
import 'package:fluffychat/pangea/controllers/my_analytics_controller.dart';
import 'package:fluffychat/pangea/controllers/permissions_controller.dart';
import 'package:fluffychat/pangea/controllers/subscription_controller.dart';
import 'package:fluffychat/pangea/controllers/user_controller.dart';
import 'package:fluffychat/pangea/controllers/word_net_controller.dart';
import 'package:fluffychat/pangea/guard/p_vguard.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/pangea/utils/instructions.dart';
import 'package:fluffychat/widgets/matrix.dart';
import '../../config/app_config.dart';
import '../utils/firebase_analytics.dart';
import '../utils/p_store.dart';
import 'message_analytics_controller.dart';

class PangeaController {
  ///pangeaControllers
  late UserController userController;
  late LanguageController languageController;
  late ClassController classController;
  late PermissionsController permissionsController;
  late AnalyticsController analytics;
  late MyAnalyticsController myAnalytics;
  late WordController wordNet;
  late LocalSettings localSettings;
  late MessageDataController messageData;
  late ContextualDefinitionController definitions;
  late InstructionsController instructions;
  late SubscriptionController subscriptionController;

  ///store Services
  late PLocalStore pStoreService;
  final pLanguageStore = PangeaLanguage();

  ///Matrix Variables
  MatrixState matrixState;
  Matrix matrix;

  int? randomint;
  PangeaController({required this.matrix, required this.matrixState}) {
    _setup();
    _subscribeToMatrixStreams();
    randomint = Random().nextInt(2000);
  }

  /// Pangea Initialization
  void _setup() {
    _addRefInObjects();
  }

  void afterSyncAndFirstLoginInitialization(BuildContext context) {
    classController.checkForClassCodeAndSubscription(context);

    // startChatWithBotIfNotPresent();

    classController.fixClassPowerLevels();
  }

  /// Initialize controllers
  _addRefInObjects() {
    pStoreService = PLocalStore(pangeaController: this);
    userController = UserController(this);
    languageController = LanguageController(this);
    localSettings = LocalSettings(this);
    classController = ClassController(this);
    permissionsController = PermissionsController(this);
    analytics = AnalyticsController(this);
    myAnalytics = MyAnalyticsController(this);
    messageData = MessageDataController(this);
    wordNet = WordController(this);
    definitions = ContextualDefinitionController(this);
    instructions = InstructionsController(this);
    subscriptionController = SubscriptionController(this);
    PAuthGaurd.pController = this;
  }

  _logOutfromPangea() {
    debugPrint("Pangea logout");
    GoogleAnalytics.logout();
    pStoreService.clearStorage();
  }

  Future<void> checkHomeServerAction() async {
    if (matrixState.getLoginClient().homeserver != null) {
      await Future.delayed(Duration.zero);
      return;
    }

    final String homeServer =
        AppConfig.defaultHomeserver.trim().toLowerCase().replaceAll(' ', '-');
    var homeserver = Uri.parse(homeServer);
    if (homeserver.scheme.isEmpty) {
      homeserver = Uri.https(homeServer, '');
    }

    matrixState.loginHomeserverSummary =
        await matrixState.getLoginClient().checkHomeserver(homeserver);
    final ssoSupported = matrixState.loginHomeserverSummary!.loginFlows
        .any((flow) => flow.type == 'm.login.sso');

    try {
      await matrixState.getLoginClient().register();
      matrixState.loginRegistrationSupported = true;
    } on MatrixException catch (e) {
      matrixState.loginRegistrationSupported =
          e.requireAdditionalAuthentication;
    }

    //  setState(() => error = (e).toLocalizedString(context));
  }

  /// check user information if not found then redirect to Date of birth page
  _handleLoginStateChange(LoginState state) {
    if (state != LoginState.loggedIn) {
      _logOutfromPangea();
    }
    Sentry.configureScope(
      (scope) => scope.setUser(SentryUser(id: matrixState.client.userID)),
    );
    GoogleAnalytics.analyticsUserUpdate(matrixState.client.userID);
  }

  // void startChatWithBotIfNotPresent() {
  //   Future.delayed(const Duration(milliseconds: 5000), () async {
  //     try {
  //       if (pStoreService.read("started_bot_chat", addClientIdToKey: false) ??
  //           false) {
  //         return;
  //       }
  //       await pStoreService.save("started_bot_chat", true,
  //           addClientIdToKey: false);
  //       final rooms = matrixState.client.rooms;

  //       await matrixState.client.startDirectChat(
  //         BotName.byEnvironment,
  //         enableEncryption: false,
  //       );
  //     } catch (err, stack) {
  //       debugger(when: kDebugMode);
  //       ErrorHandler.logError(e: err, s: stack);
  //     }
  //   });
  // }

  void startChatWithBotIfNotPresent() {
    Future.delayed(const Duration(milliseconds: 10000), () async {
      try {
        await matrixState.client.startDirectChat(
          BotName.byEnvironment,
          enableEncryption: false,
        );
      } catch (err, stack) {
        debugger(when: kDebugMode);
        ErrorHandler.logError(e: err, s: stack);
      }
    });
  }

  _handleJoinEvent(SyncUpdate syncUpdate) {
    // for (final joinedRoomUpdate in syncUpdate.rooms!.join!.entries) {
    //   debugPrint(
    //       "room update for ${joinedRoomUpdate.key} - ${joinedRoomUpdate.value}");
    // }
  }

  _handleOnSyncUpdate(SyncUpdate syncUpdate) {
    // debugPrint(syncUpdate.toString());
  }

  _handleSyncStatusFinished(SyncStatusUpdate event) {
    //might be useful to do something periodically, probably be overkill
  }

  void _subscribeToMatrixStreams() {
    matrixState.client.onLoginStateChanged.stream
        .listen(_handleLoginStateChange);

    // matrixState.client.onSyncStatus.stream
    //     .where((SyncStatusUpdate event) => event.status == SyncStatus.finished)
    //     .listen(_handleSyncStatusFinished);

    //PTODO - listen to incoming invites and autojoin if in class
    // matrixState.client.onSync.stream
    //     .where((event) => event.rooms?.invite?.isNotEmpty ?? false)
    //     .listen((SyncUpdate event) {
    // });

    // matrixState.client.onSync.stream.listen(_handleOnSyncUpdate);
  }

  Future<void> inviteBotToExistingSpaces() async {
    final List<Room> spaces =
        matrixState.client.rooms.where((room) => room.isSpace).toList();
    for (final Room space in spaces) {
      List<User> participants;
      try {
        participants = await space.requestParticipants();
      } catch (err) {
        ErrorHandler.logError(
          e: "Failed to fetch participants for space ${space.id}",
        );
        continue;
      }
      final List<String> userIds = participants.map((user) => user.id).toList();
      if (space.canInvite && !userIds.contains(BotName.byEnvironment)) {
        try {
          await space.invite(BotName.byEnvironment);
          await space.setPower(
            BotName.byEnvironment,
            ClassDefaultValues.powerLevelOfAdmin,
          );
        } catch (err) {
          ErrorHandler.logError(
            e: "Failed to invite pangea bot to space ${space.id}",
          );
        }
      }
    }
  }
}