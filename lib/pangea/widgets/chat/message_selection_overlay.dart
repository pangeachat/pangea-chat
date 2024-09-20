import 'dart:developer';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/events/message.dart';
import 'package:fluffychat/pangea/enum/message_mode_enum.dart';
import 'package:fluffychat/pangea/matrix_event_wrappers/pangea_message_event.dart';
import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:fluffychat/pangea/widgets/chat/message_toolbar.dart';
import 'package:fluffychat/pangea/widgets/chat/overlay_footer.dart';
import 'package:fluffychat/pangea/widgets/chat/overlay_header.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class MessageSelectionOverlay extends StatefulWidget {
  final ChatController chatController;
  final Event event;
  final Event? nextEvent;
  final Event? prevEvent;
  final PangeaMessageEvent pangeaMessageEvent;

  const MessageSelectionOverlay({
    required this.chatController,
    required this.event,
    required this.pangeaMessageEvent,
    this.nextEvent,
    this.prevEvent,
    super.key,
  });

  @override
  MessageOverlayController createState() => MessageOverlayController();
}

class MessageOverlayController extends State<MessageSelectionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double>? _overlayPositionAnimation;

  MessageMode toolbarMode = MessageMode.translation;
  final List<int> selectedTokenIndicies = [];

  int activitiesToComplete = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: FluffyThemes.animationDuration,
    );

    setInitialToolbarMode();
  }

  int get activitiesLeftToComplete =>
      activitiesToComplete -
      widget.pangeaMessageEvent.numberOfActivitiesCompleted;

  /// In some cases, we need to exit the practice flow and let the user
  /// interact with the toolbar without completing activities
  void exitPracticeFlow() {
    activitiesToComplete = 0;
    setInitialToolbarMode();
    setState(() {});
  }

  Future<void> setInitialToolbarMode() async {
    if (activitiesLeftToComplete > 0) {
      toolbarMode = MessageMode.practiceActivity;
      return;
    }

    if (widget.pangeaMessageEvent.isAudioMessage) {
      toolbarMode = MessageMode.speechToText;
      return;
    }

    if (MatrixState.pangeaController.userController.profile.userSettings
        .autoPlayMessages) {
      toolbarMode = MessageMode.textToSpeech;
      return;
    }
    setState(() {});
  }

  updateToolbarMode(MessageMode mode) {
    setState(() {
      toolbarMode = mode;
    });
  }

  String get selectedText {
    final tokens = widget.pangeaMessageEvent.originalSent?.tokens;

    if (tokens == null || selectedTokenIndicies.isEmpty) {
      debugger(when: kDebugMode);
      return '';
    }

    final startTokenIndex = selectedTokenIndicies[0];
    final endTokenIndex =
        selectedTokenIndicies[selectedTokenIndicies.length - 1];

    return PangeaToken.reconstructText(tokens, startTokenIndex, endTokenIndex);
  }

  void onClickOverlayMessageToken(
    PangeaMessageEvent pangeaMessageEvent,
    int tokenIndex,
  ) {
    if (pangeaMessageEvent.originalSent?.tokens == null ||
        tokenIndex < 0 ||
        tokenIndex >= pangeaMessageEvent.originalSent!.tokens!.length) {
      selectedTokenIndicies.clear();
      return;
    }

    // if there's stuff that's already selected, then we already ahve a sentence deselect
    if (selectedTokenIndicies.isNotEmpty) {
      final bool listContainedIndex =
          selectedTokenIndicies.contains(tokenIndex);

      selectedTokenIndicies.clear();
      if (!listContainedIndex) {
        selectedTokenIndicies.add(tokenIndex);
      }
    }

    // TODO
    // if this is already selected, see if there's a sentence and select that

    // if nothing is selected, select one token
    else {
      selectedTokenIndicies.add(tokenIndex);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (messageSize == null || messageOffset == null) {
      return;
    }

    // position the overlay directly over the underlying message
    final headerBottomOffset = screenHeight - headerHeight;
    final footerBottomOffset = footerHeight;
    final currentBottomOffset =
        screenHeight - messageOffset!.dy - messageSize!.height;

    final bool hasHeaderOverflow =
        messageOffset!.dy < (AppConfig.toolbarMaxHeight + headerHeight);
    final bool hasFooterOverflow = footerHeight > currentBottomOffset;

    if (!hasHeaderOverflow && !hasFooterOverflow) return;

    double scrollOffset = 0;
    double animationEndOffset = 0;

    final midpoint = (headerBottomOffset + footerBottomOffset) / 2;

    // if the overlay would have a footer overflow for this message,
    // check if shifting the overlay up could cause a header overflow
    final bottomOffsetDifference = footerHeight - currentBottomOffset;
    final newTopOffset = messageOffset!.dy - bottomOffsetDifference;
    final bool upshiftCausesHeaderOverflow = hasFooterOverflow &&
        newTopOffset < (headerHeight + AppConfig.toolbarMaxHeight);

    if (hasHeaderOverflow || upshiftCausesHeaderOverflow) {
      animationEndOffset = midpoint - messageSize!.height;
      final totalTopOffset =
          animationEndOffset + messageSize!.height + AppConfig.toolbarMaxHeight;
      final remainingSpace = screenHeight - totalTopOffset;
      if (remainingSpace < headerHeight) {
        // the overlay could run over the header, so it needs to be shifted down
        animationEndOffset -= (headerHeight - remainingSpace);
      }
      scrollOffset = animationEndOffset - currentBottomOffset;
    } else if (hasFooterOverflow) {
      scrollOffset = footerHeight - currentBottomOffset;
      animationEndOffset = footerHeight;
    }

    _overlayPositionAnimation = Tween<double>(
      begin: currentBottomOffset,
      end: animationEndOffset,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: FluffyThemes.animationCurve,
      ),
    );

    widget.chatController.scrollController.animateTo(
      widget.chatController.scrollController.offset - scrollOffset,
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  RenderBox? get messageRenderBox => MatrixState.pAnyState.getRenderBox(
        widget.event.eventId,
      );

  Size? get messageSize => messageRenderBox?.size;
  Offset? get messageOffset => messageRenderBox?.localToGlobal(Offset.zero);

  // height of the reply/forward bar + the reaction picker + contextual padding
  double get footerHeight =>
      48 + 56 + (FluffyThemes.isColumnMode(context) ? 16.0 : 8.0);

  double get headerHeight =>
      (Theme.of(context).appBarTheme.toolbarHeight ?? 56) +
      MediaQuery.of(context).padding.top;

  double get screenHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    final bool showDetails = (Matrix.of(context)
                .store
                .getBool(SettingKeys.displayChatDetailsColumn) ??
            false) &&
        FluffyThemes.isThreeColumnMode(context) &&
        widget.chatController.room.membership == Membership.join;

    final overlayMessage = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: FluffyThemes.columnWidth * 2.5,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: widget.pangeaMessageEvent.ownMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: widget.pangeaMessageEvent.ownMessage
                        ? 0
                        : Avatar.defaultSize + 16,
                    right: widget.pangeaMessageEvent.ownMessage ? 8 : 0,
                  ),
                  child: MessageToolbar(
                    pangeaMessageEvent: widget.pangeaMessageEvent,
                    overLayController: this,
                  ),
                ),
              ],
            ),
            Message(
              widget.event,
              onSwipe: () => {},
              onInfoTab: (_) => {},
              onAvatarTab: (_) => {},
              scrollToEventId: (_) => {},
              onSelect: (_) => {},
              immersionMode: widget.chatController.choreographer.immersionMode,
              controller: widget.chatController,
              timeline: widget.chatController.timeline!,
              overlayController: this,
              animateIn: false,
              nextEvent: widget.nextEvent,
              previousEvent: widget.prevEvent,
            ),
          ],
        ),
      ),
    );

    final positionedOverlayMessage = _overlayPositionAnimation == null
        ? Positioned(
            left: 0,
            right: showDetails ? FluffyThemes.columnWidth : 0,
            bottom: screenHeight - messageOffset!.dy - messageSize!.height,
            child: Align(
              alignment: Alignment.center,
              child: overlayMessage,
            ),
          )
        : AnimatedBuilder(
            animation: _overlayPositionAnimation!,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: showDetails ? FluffyThemes.columnWidth : 0,
                bottom: _overlayPositionAnimation!.value,
                child: Align(
                  alignment: Alignment.center,
                  child: overlayMessage,
                ),
              );
            },
          );

    return Padding(
      padding: EdgeInsets.only(
        left: FluffyThemes.isColumnMode(context) ? 8.0 : 0.0,
        right: FluffyThemes.isColumnMode(context) ? 8.0 : 0.0,
      ),
      child: Stack(
        children: [
          positionedOverlayMessage,
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OverlayFooter(controller: widget.chatController),
                    ],
                  ),
                ),
                if (showDetails)
                  const SizedBox(
                    width: FluffyThemes.columnWidth,
                  ),
              ],
            ),
          ),
          Material(
            child: OverlayHeader(controller: widget.chatController),
          ),
        ],
      ),
    );
  }
}
