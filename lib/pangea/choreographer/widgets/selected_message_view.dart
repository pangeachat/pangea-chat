import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pages/chat/chat.dart';
import 'package:fluffychat/pages/chat/chat_app_bar_list_tile.dart';
import 'package:fluffychat/pages/chat/chat_app_bar_title.dart';
import 'package:fluffychat/pages/chat/pinned_events.dart';
import 'package:fluffychat/pages/chat/reactions_picker.dart';
import 'package:fluffychat/pages/chat/reply_display.dart';
import 'package:fluffychat/pangea/choreographer/widgets/it_bar.dart';
import 'package:fluffychat/pangea/widgets/chat/message_toolbar.dart';
import 'package:fluffychat/widgets/connection_status_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

enum _EventContextAction { info, report }

class SelectedMessageView extends StatelessWidget {
  final ChatController controller;
  final Room room;
  final ToolbarDisplayController? toolbarController;

  const SelectedMessageView(
    this.controller,
    this.room, {
    this.toolbarController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Close keyboard, if open
    FocusManager.instance.primaryFocus?.unfocus();
    final bottomSheetPadding = FluffyThemes.isColumnMode(context) ? 16.0 : 8.0;
    final selectedEvent = controller.selectedEvents.single;

    final scrollUpBannerEventId = controller.scrollUpBannerEventId;
    var appbarBottomHeight = 0.0;
    if (controller.room.pinnedEventIds.isNotEmpty) {
      appbarBottomHeight += 42;
    }
    if (scrollUpBannerEventId != null) {
      appbarBottomHeight += 42;
    }

    final tombstoneEvent = controller.room.getState(EventTypes.RoomTombstone);
    if (tombstoneEvent != null) {
      appbarBottomHeight += 42;
    }

    return Scaffold(
      appBar: AppBar(
        actionsIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: controller.clearSelectedEvents,
          tooltip: L10n.of(context)!.close,
          color: Theme.of(context).colorScheme.primary,
        ),
        titleSpacing: 0,
        title: ChatAppBarTitle(controller),
        actions: [
          if (controller.canEditSelectedEvents)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: L10n.of(context)!.edit,
              onPressed: controller.editSelectedEventAction,
            ),
          if (selectedEvent.messageType == MessageTypes.Text)
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: L10n.of(context)!.copy,
              onPressed: controller.copyEventsAction,
            ),
          if (controller.canSaveSelectedEvent)
            // Use builder context to correctly position the share dialog on iPad
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.adaptive.share),
                tooltip: L10n.of(context)!.share,
                onPressed: () => controller.saveSelectedEvent(context),
              ),
            ),
          if (controller.canPinSelectedEvents)
            IconButton(
              icon: const Icon(Icons.push_pin_outlined),
              onPressed: controller.pinEvent,
              tooltip: L10n.of(context)!.pinMessage,
            ),
          if (controller.canRedactSelectedEvents)
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              tooltip: L10n.of(context)!.redactMessage,
              onPressed: controller.redactEventsAction,
            ),
          PopupMenuButton<_EventContextAction>(
            onSelected: (action) {
              switch (action) {
                case _EventContextAction.info:
                  controller.showEventInfo();
                  controller.clearSelectedEvents();
                  break;
                case _EventContextAction.report:
                  controller.reportEventAction();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _EventContextAction.info,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outlined),
                    const SizedBox(width: 12),
                    Text(L10n.of(context)!.messageInfo),
                  ],
                ),
              ),
              if (selectedEvent.status.isSent)
                PopupMenuItem(
                  value: _EventContextAction.report,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(L10n.of(context)!.reportMessage),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(appbarBottomHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinnedEvents(controller),
              if (tombstoneEvent != null)
                ChatAppBarListTile(
                  title: tombstoneEvent.parsedTombstoneContent.body,
                  leading: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.upgrade_outlined),
                  ),
                  trailing: TextButton(
                    onPressed: controller.goToNewRoomAction,
                    child: Text(L10n.of(context)!.goToTheNewRoom),
                  ),
                ),
              if (scrollUpBannerEventId != null)
                ChatAppBarListTile(
                  leading: IconButton(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    icon: const Icon(Icons.close),
                    tooltip: L10n.of(context)!.close,
                    onPressed: () {
                      controller.discardScrollUpBannerEventId();
                      controller.setReadMarker();
                    },
                  ),
                  title: L10n.of(context)!.jumpToLastReadMessage,
                  trailing: TextButton(
                    onPressed: () {
                      controller.scrollToEventId(
                        scrollUpBannerEventId,
                      );
                      controller.discardScrollUpBannerEventId();
                    },
                    child: Text(L10n.of(context)!.jump),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Center(
        child: toolbarController?.getToolbar(context),
      ),
      bottomSheet: Container(
        margin: EdgeInsets.only(
          bottom: bottomSheetPadding,
          left: bottomSheetPadding,
          right: bottomSheetPadding,
        ),
        constraints: const BoxConstraints(
          maxWidth: FluffyThemes.columnWidth * 2.5,
        ),
        alignment: Alignment.center,
        child: Material(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.all(
            Radius.circular(24),
          ),
          child: Column(
            children: [
              const ConnectionStatusHeader(),
              ITBar(
                choreographer: controller.choreographer,
              ),
              ReactionsPicker(controller),
              ReplyDisplay(controller),
            ],
          ),
        ),
      ),
    );
  }
}
