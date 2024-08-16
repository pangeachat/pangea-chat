import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:flutter/material.dart';

class GameConstants {
  static const int timerMaxSeconds = 120;
  static Color roundColor = const Color.fromARGB(255, 209, 0, 0);
  static Color betweenRoundColor = const Color.fromARGB(255, 0, 176, 12);
  static String gameMaster = BotName.byEnvironment;
}
