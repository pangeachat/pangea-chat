import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/analytics/constants/analytics_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class LevelUpAnimation extends StatefulWidget {
  final int level;

  const LevelUpAnimation({
    required this.level,
    super.key,
  });

  @override
  LevelUpAnimationState createState() => LevelUpAnimationState();
}

class LevelUpAnimationState extends State<LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start just below the screen
      end: Offset.zero, // Slide into its position
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Image.network(
      "${AppConfig.assetsBaseURL}/${AnalyticsConstants.levelUpImageFileName}",
      height: kIsWeb ? 350 : 250,
    );

    if (!kIsWeb) {
      content = OverflowBox(
        maxWidth: double.infinity,
        child: content,
      );
    }

    return GestureDetector(
      onDoubleTap: Navigator.of(context).pop,
      child: Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                content,
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    L10n.of(context).levelPopupTitle(widget.level),
                    style: const TextStyle(
                      fontSize: kIsWeb ? 40 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
