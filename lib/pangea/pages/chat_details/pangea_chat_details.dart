import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fluffychat/pages/chat_details/chat_details.dart';
import 'package:fluffychat/pages/chat_details/participant_list_item.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/pages/class_settings/class_name_header.dart';
import 'package:fluffychat/pangea/pages/class_settings/p_class_widgets/class_details_toggle_add_students_tile.dart';
import 'package:fluffychat/pangea/pages/class_settings/p_class_widgets/room_capacity_button.dart';
import 'package:fluffychat/pangea/utils/download_chat.dart';
import 'package:fluffychat/pangea/widgets/chat/visibility_toggle.dart';
import 'package:fluffychat/pangea/widgets/conversation_bot/conversation_bot_settings.dart';
import 'package:fluffychat/utils/fluffy_share.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/widgets/avatar.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class PangeaChatDetailsView extends StatelessWidget {
  final ChatDetailsController controller;

  const PangeaChatDetailsView(this.controller, {super.key});

  void _downloadChat(BuildContext context) async {
    if (controller.roomId == null) return;
    final Room? room =
        Matrix.of(context).client.getRoomById(controller.roomId!);
    if (room == null) return;

    final type = await showConfirmationDialog(
      context: context,
      title: L10n.of(context)!.downloadGroupText,
      actions: [
        AlertDialogAction(
          key: DownloadType.csv,
          label: L10n.of(context)!.downloadCSVFile,
        ),
        AlertDialogAction(
          key: DownloadType.txt,
          label: L10n.of(context)!.downloadTxtFile,
        ),
        AlertDialogAction(
          key: DownloadType.xlsx,
          label: L10n.of(context)!.downloadXLSXFile,
        ),
      ],
    );
    if (type == null) return;
    downloadChat(room, type, context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final room = Matrix.of(context).client.getRoomById(controller.roomId!);
    if (room == null || room.membership == Membership.leave) {
      return Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context)!.oopsSomethingWentWrong),
        ),
        body: Center(
          child: Text(L10n.of(context)!.youAreNoLongerParticipatingInThisChat),
        ),
      );
    }

    final bool isGroupChat = !room.isDirectChat && !room.isSpace;

    return StreamBuilder(
      stream: room.client.onRoomState.stream
          .where((update) => update.roomId == room.id),
      builder: (context, snapshot) {
        var members = room.getParticipants().toList()
          ..sort((b, a) => a.powerLevel.compareTo(b.powerLevel));
        members = members.take(10).toList();
        final actualMembersCount = (room.summary.mInvitedMemberCount ?? 0) +
            (room.summary.mJoinedMemberCount ?? 0);
        final canRequestMoreMembers = members.length < actualMembersCount;
        final iconColor = theme.textTheme.bodyLarge!.color;
        final displayname = room.getLocalizedDisplayname(
          MatrixLocals(L10n.of(context)!),
        );
        return Scaffold(
          appBar: AppBar(
            leading: controller.widget.embeddedCloseButton ??
                const Center(child: BackButton()),
            elevation: theme.appBarTheme.elevation,
            title: ClassNameHeader(
              controller: controller,
              room: room,
            ),
            backgroundColor: theme.appBarTheme.backgroundColor,
          ),
          body: MaxWidthBody(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: members.length + 1 + (canRequestMoreMembers ? 1 : 0),
              itemBuilder: (BuildContext context, int i) => i == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Stack(
                                children: [
                                  Hero(
                                    tag:
                                        controller.widget.embeddedCloseButton !=
                                                null
                                            ? 'embedded_content_banner'
                                            : 'content_banner',
                                    child: Avatar(
                                      mxContent: room.avatar,
                                      name: displayname,
                                      size: Avatar.defaultSize * 2.5,
                                    ),
                                  ),
                                  if (!room.isDirectChat &&
                                      room.canChangeStateEvent(
                                        EventTypes.RoomAvatar,
                                      ))
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: FloatingActionButton.small(
                                        onPressed: controller.setAvatarAction,
                                        heroTag: null,
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => room.isDirectChat
                                        ? null
                                        : room.canChangeStateEvent(
                                            EventTypes.RoomName,
                                          )
                                            ? controller.setDisplaynameAction()
                                            : FluffyShare.share(
                                                displayname,
                                                context,
                                                copyOnly: true,
                                              ),
                                    icon: Icon(
                                      room.isDirectChat
                                          ? Icons.chat_bubble_outline
                                          : room.canChangeStateEvent(
                                              EventTypes.RoomName,
                                            )
                                              ? Icons.edit_outlined
                                              : Icons.copy_outlined,
                                      size: 16,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.onSurface,
                                    ),
                                    label: Text(
                                      room.isDirectChat
                                          ? L10n.of(context)!.directChat
                                          : displayname,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => room.isDirectChat
                                        ? null
                                        : context.push(
                                            '/rooms/${controller.roomId}/details/members',
                                          ),
                                    icon: const Icon(
                                      Icons.group_outlined,
                                      size: 14,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.secondary,
                                    ),
                                    label: Text(
                                      L10n.of(context)!.countParticipants(
                                        actualMembersCount,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: controller.setChatDescription,
                                    icon: const Icon(
                                      Icons.description_outlined,
                                      size: 14,
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.secondary,
                                    ),
                                    label: Text(
                                      room.topic.isEmpty
                                          ? room.isSpace
                                              ? L10n.of(context)!
                                                  .spaceDescription
                                              : L10n.of(context)!
                                                  .chatDescription
                                          : room.topic,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: theme.dividerColor, height: 1),
                        if (isGroupChat && room.canInvite)
                          ConversationBotSettings(
                            key: controller.addConversationBotKey,
                            room: room,
                          ),
                        if (isGroupChat && room.canInvite)
                          Divider(color: theme.dividerColor, height: 1),
                        if (room.canInvite && !room.isDirectChat)
                          ListTile(
                            title: Text(
                              L10n.of(context)!.inviteStudentByUserName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              foregroundColor:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                              child: const Icon(
                                Icons.person_add_outlined,
                              ),
                            ),
                            onTap: () => context.go('/rooms/${room.id}/invite'),
                          ),
                        if (room.canInvite && !room.isDirectChat)
                          Divider(color: theme.dividerColor, height: 1),
                        if (room.isSpace && room.isRoomAdmin)
                          SpaceDetailsToggleAddStudentsTile(
                            controller: controller,
                          ),
                        if (room.isSpace && room.isRoomAdmin)
                          Divider(color: theme.dividerColor, height: 1),
                        if (isGroupChat && room.isRoomAdmin)
                          ListTile(
                            title: Text(
                              L10n.of(context)!.editChatPermissions,
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              L10n.of(context)!.whoCanPerformWhichAction,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              foregroundColor: iconColor,
                              child: const Icon(
                                Icons.manage_accounts_outlined,
                              ),
                            ),
                            onTap: () => context.push(
                              '/rooms/${room.id}/details/permissions',
                            ),
                          ),
                        if (isGroupChat && room.isRoomAdmin)
                          Divider(color: theme.dividerColor, height: 1),
                        if (room.isRoomAdmin)
                          VisibilityToggle(
                            room: room,
                            setVisibility: controller.setVisibility,
                            iconColor: iconColor,
                          ),
                        if (room.isRoomAdmin)
                          Divider(color: theme.dividerColor, height: 1),
                        RoomCapacityButton(
                          room: room,
                          controller: controller,
                        ),
                        Divider(color: theme.dividerColor, height: 1),
                        if (isGroupChat)
                          ListTile(
                            title: Text(
                              L10n.of(context)!.downloadGroupText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              foregroundColor: iconColor,
                              child: const Icon(
                                Icons.download_outlined,
                              ),
                            ),
                            onTap: () => _downloadChat(context),
                          ),
                        if (isGroupChat)
                          Divider(color: theme.dividerColor, height: 1),
                        if (isGroupChat)
                          ListTile(
                            title: Text(
                              L10n.of(context)!.muteChat,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              foregroundColor: iconColor,
                              child: Icon(
                                room.pushRuleState == PushRuleState.notify
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                              ),
                            ),
                            onTap: controller.toggleMute,
                          ),
                        if (isGroupChat)
                          Divider(color: theme.dividerColor, height: 1),
                        ListTile(
                          title: Text(
                            L10n.of(context)!.leave,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            foregroundColor: iconColor,
                            child: const Icon(
                              Icons.logout_outlined,
                            ),
                          ),
                          onTap: () async {
                            var confirmed = OkCancelResult.ok;
                            var shouldGo = false;
                            // If user is only admin, room will be archived
                            final onlyAdmin = await room.isOnlyAdmin();
                            // archiveSpace has its own popup; only show if not space
                            if (!room.isSpace) {
                              confirmed = await showOkCancelAlertDialog(
                                useRootNavigator: false,
                                context: context,
                                title: L10n.of(context)!.areYouSure,
                                okLabel: L10n.of(context)!.ok,
                                cancelLabel: L10n.of(context)!.cancel,
                                message: onlyAdmin
                                    ? L10n.of(context)!.onlyAdminDescription
                                    : L10n.of(context)!.leaveRoomDescription,
                              );
                            }
                            if (confirmed == OkCancelResult.ok) {
                              if (room.isSpace) {
                                shouldGo = onlyAdmin
                                    ? await room.archiveSpace(
                                        context,
                                        Matrix.of(context).client,
                                        onlyAdmin: true,
                                      )
                                    : await room.leaveSpace(
                                        context,
                                        Matrix.of(context).client,
                                      );
                              } else {
                                final success = await showFutureLoadingDialog(
                                  context: context,
                                  future: () async {
                                    onlyAdmin
                                        ? await room.archive()
                                        : await room.leave();
                                  },
                                );
                                shouldGo = (success.error == null);
                              }
                              if (shouldGo) {
                                context.go('/rooms');
                              }
                            }
                          },
                        ),
                        Divider(color: theme.dividerColor, height: 1),
                        ListTile(
                          title: Text(
                            L10n.of(context)!.countParticipants(
                              actualMembersCount.toString(),
                            ),
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : i < members.length + 1
                      ? ParticipantListItem(members[i - 1])
                      : ListTile(
                          title: Text(
                            L10n.of(context)!.loadCountMoreParticipants(
                              (actualMembersCount - members.length).toString(),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            child: const Icon(
                              Icons.group_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () => context.push(
                            '/rooms/${controller.roomId!}/details/members',
                          ),
                          trailing: const Icon(Icons.chevron_right_outlined),
                        ),
            ),
          ),
        );
      },
    );
  }
}