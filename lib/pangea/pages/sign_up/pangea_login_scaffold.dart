import 'dart:typed_data';

import 'package:fluffychat/config/app_config.dart';
import 'package:flutter/material.dart';

class PangeaLoginScaffold extends StatelessWidget {
  final String mainAssetPath;
  final Uint8List? mainAssetBytes;
  final List<Widget> children;
  final bool showAppName;

  const PangeaLoginScaffold({
    required this.children,
    this.mainAssetPath = "pangea/PangeaChat_Glow_Logo.png",
    this.mainAssetBytes,
    this.showAppName = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: ClipOval(
                        child: mainAssetBytes != null
                            ? Image.memory(
                                mainAssetBytes!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, s) {
                                  return Container(color: Colors.white);
                                }, // scale properly without warping
                              )
                            : Image.asset(
                                mainAssetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, s) {
                                  return Container(color: Colors.white);
                                }, // scale properly without warping
                              ),
                      ),
                    ),
                    if (showAppName)
                      Text(
                        AppConfig.applicationName,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    const SizedBox(height: 24),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
