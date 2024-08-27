import 'package:fluffychat/pangea/utils/bot_name.dart';

class GameConstants {
  static const int timerMaxSeconds = 120;
  static String gameMaster = BotName.byEnvironment;
  static const int pointsToWin = 10;
  static const List<String> voteEmojis = ['👍'];
}
