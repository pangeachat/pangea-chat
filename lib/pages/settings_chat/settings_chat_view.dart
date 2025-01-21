import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/config/setting_keys.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/widgets/layouts/max_width_body.dart';
import 'package:fluffychat/widgets/settings_switch_list_tile.dart';
import 'settings_chat.dart';

class SettingsChatView extends StatelessWidget {
  final SettingsChatController controller;
  const SettingsChatView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context).chat)),
      body: ListTileTheme(
        iconColor: theme.textTheme.bodyLarge!.color,
        child: MaxWidthBody(
          child: Column(
            children: [
              // #Pangea
              // SettingsSwitchListTile.adaptive(
              //   title: L10n.of(context).formattedMessages,
              //   subtitle: L10n.of(context).formattedMessagesDescription,
              //   onChanged: (b) => AppConfig.renderHtml = b,
              //   storeKey: SettingKeys.renderHtml,
              //   defaultValue: AppConfig.renderHtml,
              // ),
              // SettingsSwitchListTile.adaptive(
              //   title: L10n.of(context).hideMemberChangesInPublicChats,
              //   subtitle: L10n.of(context).hideMemberChangesInPublicChatsBody,
              //   onChanged: (b) => AppConfig.hideUnimportantStateEvents = b,
              //   storeKey: SettingKeys.hideUnimportantStateEvents,
              //   defaultValue: AppConfig.hideUnimportantStateEvents,
              // ),
              // Pangea#
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context).hideRedactedMessages,
                subtitle: L10n.of(context).hideRedactedMessagesBody,
                onChanged: (b) => AppConfig.hideRedactedEvents = b,
                storeKey: SettingKeys.hideRedactedEvents,
                defaultValue: AppConfig.hideRedactedEvents,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context).hideInvalidOrUnknownMessageFormats,
                onChanged: (b) => AppConfig.hideUnknownEvents = b,
                storeKey: SettingKeys.hideUnknownEvents,
                defaultValue: AppConfig.hideUnknownEvents,
              ),
              // #Pangea
              // if (PlatformInfos.isMobile)
              //   SettingsSwitchListTile.adaptive(
              //     title: L10n.of(context).autoplayImages,
              //     onChanged: (b) => AppConfig.autoplayImages = b,
              //     storeKey: SettingKeys.autoplayImages,
              //     defaultValue: AppConfig.autoplayImages,
              //   ),
              // Pangea#
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context).sendOnEnter,
                onChanged: (b) => AppConfig.sendOnEnter = b,
                storeKey: SettingKeys.sendOnEnter,
                defaultValue: AppConfig.sendOnEnter ?? !PlatformInfos.isMobile,
              ),
              SettingsSwitchListTile.adaptive(
                title: L10n.of(context).swipeRightToLeftToReply,
                onChanged: (b) => AppConfig.swipeRightToLeftToReply = b,
                storeKey: SettingKeys.swipeRightToLeftToReply,
                defaultValue: AppConfig.swipeRightToLeftToReply,
              ),
              // #Pangea
              // Divider(color: theme.dividerColor),
              // ListTile(
              //   title: Text(
              //     L10n.of(context).customEmojisAndStickers,
              //     style: TextStyle(
              //       color: theme.colorScheme.secondary,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // ListTile(
              //   title: Text(L10n.of(context).customEmojisAndStickers),
              //   subtitle: Text(L10n.of(context).customEmojisAndStickersBody),
              //   onTap: () => context.go('/rooms/settings/chat/emotes'),
              //   trailing: const Padding(
              //     padding: EdgeInsets.all(16.0),
              //     child: Icon(Icons.chevron_right_outlined),
              //   ),
              // ),
              // Divider(color: theme.dividerColor),
              // ListTile(
              //   title: Text(
              //     L10n.of(context).calls,
              //     style: TextStyle(
              //       color: theme.colorScheme.secondary,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // SettingsSwitchListTile.adaptive(
              //   title: L10n.of(context).experimentalVideoCalls,
              //   onChanged: (b) {
              //     AppConfig.experimentalVoip = b;
              //     Matrix.of(context).createVoipPlugin();
              //     return;
              //   },
              //   storeKey: SettingKeys.experimentalVoip,
              //   defaultValue: AppConfig.experimentalVoip,
              // ),
              // if (PlatformInfos.isMobile)
              //   ListTile(
              //     title: Text(L10n.of(context).callingPermissions),
              //     onTap: () =>
              //         CallKeepManager().checkoutPhoneAccountSetting(context),
              //     trailing: const Padding(
              //       padding: EdgeInsets.all(16.0),
              //       child: Icon(Icons.call),
              //     ),
              //   ),
              // Pangea#
            ],
          ),
        ),
      ),
    );
  }
}
