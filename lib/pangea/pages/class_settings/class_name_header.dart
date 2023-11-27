// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/visibility.dart' as visible;

// Package imports:
import 'package:matrix/matrix.dart';

// Project imports:
import 'package:fluffychat/pages/chat_details/chat_details.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension.dart';

class ClassNameHeader extends StatelessWidget {
  final Room room;
  final ChatDetailsController controller;
  const ClassNameHeader({
    Key? key,
    required this.room,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed:
          room.canSendDefaultStates ? controller.setDisplaynameAction : null,
      onHover: room.canSendDefaultStates ? controller.hoverEditNameIcon : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25),
      ),
      label: visible.Visibility(
        visible: controller.showEditNameIcon,
        child: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      icon: room.nameAndRoomTypeIcon(TextStyle(
        fontSize: 20,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      )),
      // icon: Text(
      //   room.getLocalizedDisplayname(
      //     MatrixLocals(L10n.of(context)!),
      //   ),
      //   style: TextStyle(
      //     fontSize: 20,
      //     color: Theme.of(context).textTheme.bodyText1!.color,
      //   ),
      // ),
    );
  }
}
