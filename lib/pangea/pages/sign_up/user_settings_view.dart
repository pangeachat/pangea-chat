import 'package:fluffychat/pangea/pages/sign_up/full_width_button.dart';
import 'package:fluffychat/pangea/pages/sign_up/pangea_login_scaffold.dart';
import 'package:fluffychat/pangea/pages/sign_up/user_settings.dart';
import 'package:fluffychat/pangea/widgets/user_settings/p_language_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserSettingsView extends StatelessWidget {
  final UserSettingsState controller;
  final List<String> paths;
  const UserSettingsView({
    required this.controller,
    this.paths = const [
      "assets/pangea/pangea_logo.svg",
      "",
      "",
      "",
    ],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PangeaLoginScaffold(
      children: [
        Text(L10n.of(context).chooseYourAvatar),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: paths.map((path) {
              return AvatarOption(path: path);
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: PLanguageDropdown(
            languages: controller.targetOptions,
            onChange: controller.setSelectedTargetLanguage,
            initialLanguage: controller.selectedTargetLanguage,
            isL2List: true,
          ),
        ),
        FullWidthButton(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(L10n.of(context).letsStart)],
          ),
          onPressed: controller.createUserInPangea,
        ),
      ],
    );
  }
}

class AvatarOption extends StatelessWidget {
  final String path; // Path or URL of the SVG file
  final double size; // Diameter of the circle

  const AvatarOption({
    super.key,
    required this.path,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          path,
          fit: BoxFit.cover, // Ensures the SVG scales properly without warping
        ),
      ),
    );
  }
}
