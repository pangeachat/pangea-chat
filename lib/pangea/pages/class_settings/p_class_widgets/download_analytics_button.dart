import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/widgets/future_loading_dialog.dart';
import 'package:fluffychat/widgets/matrix.dart';

class DownloadAnalyticsButton extends StatelessWidget {
  final Room space;

  const DownloadAnalyticsButton({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).textTheme.bodyLarge!.color;
    return Column(
      children: [
        ListTile(
          onTap: () {
            showFutureLoadingDialog(
              context: context,
              future: () async => MatrixState
                  .pangeaController.getAnalytics.downloadController
                  .downloadSpaceAnalytics(space, context),
            );
          },
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: iconColor,
            child: const Icon(Icons.download_outlined),
          ),
          title: Text(
            L10n.of(context).downloadSpaceAnalytics,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
