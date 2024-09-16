import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pangea/enum/message_mode_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/utils/error_handler.dart';
import 'package:fluffychat/pangea/widgets/chat/message_audio_card.dart';
import 'package:fluffychat/pangea/widgets/chat/message_speech_to_text_card.dart';
import 'package:fluffychat/pangea/widgets/chat/message_translation_card.dart';
import 'package:fluffychat/pangea/widgets/chat/message_unsubscribed_card.dart';
import 'package:fluffychat/pangea/widgets/igc/word_data_card.dart';
import 'package:fluffychat/pangea/widgets/practice_activity/practice_activity_card.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class MessageToolbar extends StatefulWidget {
  final PangeaMessageEvent pangeaMessageEvent;
  final ChatController controller;
  final MessageMode? initialMode;

  const MessageToolbar({
    super.key,
    required this.pangeaMessageEvent,
    required this.controller,
    this.initialMode,
  });

  @override
  MessageToolbarState createState() => MessageToolbarState();
}

class MessageToolbarState extends State<MessageToolbar> {
  Widget? toolbarContent;
  MessageMode? currentMode;
  bool updatingMode = false;

  void updateMode(MessageMode newMode) {
    //Early exit from the function if the widget has been unmounted to prevent updates on an inactive widget.
    if (!mounted) return;
    if (updatingMode) return;
    debugPrint("updating toolbar mode");
    final bool subscribed =
        MatrixState.pangeaController.subscriptionController.isSubscribed;

    if (!newMode.isValidMode(widget.pangeaMessageEvent.event)) {
      ErrorHandler.logError(
        e: "Invalid mode for event",
        s: StackTrace.current,
        data: {
          "newMode": newMode,
          "event": widget.pangeaMessageEvent.event,
        },
      );
      return;
    }

    // if there is an uncompleted activity, then show that
    // we don't want the user to user the tools to get the answer :P
    if (widget.pangeaMessageEvent.hasUncompletedActivity) {
      newMode = MessageMode.practiceActivity;
    }

    if (mounted) {
      setState(() {
        currentMode = newMode;
        updatingMode = true;
      });
    }

    if (!subscribed) {
      toolbarContent = MessageUnsubscribedCard(
        languageTool: newMode.title(context),
        mode: newMode,
        controller: this,
      );
    } else {
      switch (currentMode) {
        case MessageMode.translation:
          showTranslation();
          break;
        case MessageMode.textToSpeech:
          showTextToSpeech();
          break;
        case MessageMode.speechToText:
          showSpeechToText();
          break;
        case MessageMode.definition:
          showDefinition();
          break;
        case MessageMode.practiceActivity:
          showPracticeActivity();
          break;
        default:
          ErrorHandler.logError(
            e: "Invalid toolbar mode",
            s: StackTrace.current,
            data: {"newMode": newMode},
          );
          break;
      }
    }
    if (mounted) {
      setState(() {
        updatingMode = false;
      });
    }
  }

  void showTranslation() {
    debugPrint("show translation");
    toolbarContent = MessageTranslationCard(
      messageEvent: widget.pangeaMessageEvent,
      immersionMode: widget.controller.choreographer.immersionMode,
    );
  }

  void showTextToSpeech() {
    debugPrint("show text to speech");
    toolbarContent = MessageAudioCard(
      messageEvent: widget.pangeaMessageEvent,
    );
  }

  void showSpeechToText() {
    debugPrint("show speech to text");
    toolbarContent = MessageSpeechToTextCard(
      messageEvent: widget.pangeaMessageEvent,
    );
  }

  void showDefinition() {
    debugPrint("show definition");
    toolbarContent = const SelectToDefine();
  }

  void showPracticeActivity() {
    toolbarContent = PracticeActivityCard(
      pangeaMessageEvent: widget.pangeaMessageEvent,
    );
  }

  void showImage() {}

  void spellCheck() {}

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.pangeaMessageEvent.isAudioMessage) {
        updateMode(MessageMode.speechToText);
        return;
      }

      if (widget.initialMode != null) {
        updateMode(widget.initialMode!);
      } else {
        MatrixState.pangeaController.userController.profile.userSettings
                .autoPlayMessages
            ? updateMode(MessageMode.textToSpeech)
            : updateMode(MessageMode.translation);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: MatrixState.pAnyState
          .layerLinkAndKey('${widget.pangeaMessageEvent.eventId}-toolbar')
          .key,
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: AppConfig.toolbarMaxHeight,
          maxWidth: 275,
          minWidth: 275,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (toolbarContent != null)
              Flexible(
                child: SingleChildScrollView(
                  child: AnimatedSize(
                    duration: FluffyThemes.animationDuration,
                    child: toolbarContent,
                  ),
                ),
              ),
            ToolbarButtons(controller: this, width: 250),
          ],
        ),
      ),
    );
  }
}

class ToolbarSelectionArea extends StatelessWidget {
  final ChatController controller;
  final PangeaMessageEvent? pangeaMessageEvent;
  final bool isOverlay;
  final Widget child;
  final Event? nextEvent;
  final Event? prevEvent;

  const ToolbarSelectionArea({
    required this.controller,
    this.pangeaMessageEvent,
    this.isOverlay = false,
    required this.child,
    this.nextEvent,
    this.prevEvent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (pangeaMessageEvent != null && !isOverlay) {
          controller.showToolbar(
            pangeaMessageEvent!,
            nextEvent: nextEvent,
            prevEvent: prevEvent,
          );
        }
      },
      onLongPress: () {
        if (pangeaMessageEvent != null && !isOverlay) {
          controller.showToolbar(
            pangeaMessageEvent!,
            nextEvent: nextEvent,
            prevEvent: prevEvent,
          );
        }
      },
      child: child,
    );
  }
}

class ToolbarButtons extends StatefulWidget {
  final MessageToolbarState controller;
  final double width;

  const ToolbarButtons({
    required this.controller,
    required this.width,
    super.key,
  });

  @override
  ToolbarButtonsState createState() => ToolbarButtonsState();
}

class ToolbarButtonsState extends State<ToolbarButtons> {
  PangeaMessageEvent get pangeaMessageEvent =>
      widget.controller.widget.pangeaMessageEvent;

  List<MessageMode> get modes => MessageMode.values
      .where((mode) => mode.isValidMode(pangeaMessageEvent.event))
      .toList();

  final iconWidth = 36.0;
  int numActivitiesCompleted = 0;
  double get progressWidth => widget.width / modes.length;

  @override
  void initState() {
    // TODO replace with real data. This is just to demonstrate the animation
    Timer.periodic(const Duration(seconds: 5), (Timer t) {
      if (mounted) {
        setState(() => numActivitiesCompleted++);
      } else {
        t.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: widget.width,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                margin: EdgeInsets.symmetric(horizontal: iconWidth / 2),
              ),
              AnimatedContainer(
                duration: FluffyThemes.animationDuration,
                height: 12,
                width: min(
                  widget.width,
                  progressWidth * numActivitiesCompleted,
                ),
                color: const Color.fromARGB(255, 0, 190, 83),
                margin: EdgeInsets.symmetric(horizontal: iconWidth / 2),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: modes
                .mapIndexed(
                  (index, mode) => Tooltip(
                    message: mode.tooltip(context),
                    child: CircleAvatar(
                      radius: iconWidth / 2,
                      backgroundColor: mode.iconButtonColor(
                        context,
                        index,
                        numActivitiesCompleted,
                      ),
                      child: Center(
                        child: IconButton(
                          iconSize: 20,
                          icon: Icon(mode.icon),
                          onPressed:
                              mode.isUnlocked(index, numActivitiesCompleted)
                                  ? () => widget.controller.updateMode(mode)
                                  : null,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
