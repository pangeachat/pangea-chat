// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';

class PangeaLogoSvg extends StatelessWidget {
  const PangeaLogoSvg({Key? key, required this.width, this.forceColor})
      : super(key: key);

  final double width;
  final Color? forceColor;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/pangea/pangea_logo.svg',
      width: width,
      height: width,
      color: forceColor ??
          (Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary),
    );
  }
}
