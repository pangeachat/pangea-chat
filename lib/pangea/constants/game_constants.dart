import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:flutter/material.dart';

class GameConstants {
  static const int roundLength = 120;
  static const int betweenRoundLength = 5;
  static const Color roundColor = Color.fromARGB(255, 194, 0, 0);
  static const Color betweenRoundColor = Color.fromARGB(255, 5, 223, 19);
  static String gameMaster = BotName.byEnvironment;
}
