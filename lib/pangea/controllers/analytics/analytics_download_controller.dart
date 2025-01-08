import 'package:collection/collection.dart';
import 'package:excel/excel.dart';
import 'package:fluffychat/pangea/constants/class_default_values.dart';
import 'package:fluffychat/pangea/controllers/get_analytics_controller.dart';
import 'package:fluffychat/pangea/enum/analytics/analytics_summary_enum.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/models/analytics/analytics_summary_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/pangea/utils/grammar/get_grammar_copy.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

class AnalyticsDownloadController {
  final GetAnalyticsController getAnalytics;

  AnalyticsDownloadController(this.getAnalytics);

  Future<void> downloadSpaceAnalytics(
    Room space,
    BuildContext context,
  ) async {
    final l2 = MatrixState.pangeaController.languageController.userL2?.langCode;
    if (l2 == null) return;

    // load the full participant list
    final participants = await space.requestParticipants();
    final usersToDownload = participants
        .where(
          (member) =>
              space.getPowerLevelByUserId(member.id) <
                  ClassDefaultValues.powerLevelOfAdmin &&
              member.id != BotName.byEnvironment,
        )
        .toList();

    final List<List<CellValue>> rows = await Future.wait(
      usersToDownload.map(
        (user) => _getAnalyticsSummary(space, l2, user.id, context),
      ),
    ).then((rows) => rows.whereType<List<CellValue>>().toList());

    _saveExcelFile(rows, context);
  }

  Future<ConstructListModel?> _getUserAnalyticsModel(
    Room space,
    String l2,
    String userID,
  ) async {
    final userAnalyticsRoom = space.client.rooms.firstWhereOrNull((room) {
      return room.isAnalyticsRoomOfUser(userID) && room.isMadeForLang(l2);
    });
    if (userAnalyticsRoom == null) return null;
    final constructEvents =
        await userAnalyticsRoom.getAnalyticsEvents(userId: userID);
    if (constructEvents == null) return null;

    final List<OneConstructUse> uses = [];
    for (final event in constructEvents) {
      uses.addAll(event.content.uses);
    }
    return ConstructListModel(uses: uses);
  }

  String getCopy(ConstructUses use, BuildContext context) {
    return getGrammarCopy(
          category: use.category,
          lemma: use.lemma,
          context: context,
        ) ??
        use.lemma;
  }

  Future<List<CellValue>?> _getAnalyticsSummary(
    Room space,
    String l2,
    String userID,
    BuildContext context,
  ) async {
    final constructs = await _getUserAnalyticsModel(space, l2, userID);
    if (constructs == null) return null;
    final summary = AnalyticsSummaryModel.fromConstructListModel(
      constructs,
      userID,
      (c) => getCopy(c, context),
      context,
    );
    return _formatExcelRow(summary);
  }

  List<CellValue> _formatExcelRow(
    AnalyticsSummaryModel summary,
  ) {
    final List<CellValue> row = [];
    for (int i = 0; i < AnalyticsSummaryEnum.values.length; i++) {
      final key = AnalyticsSummaryEnum.values[i];
      final value = summary.getValue(key);
      if (value is int) {
        row.add(IntCellValue(value));
      } else if (value is String) {
        row.add(TextCellValue(value));
      } else if (value is List<String>) {
        row.add(TextCellValue(value.join(", ")));
      }
    }
    return row;
  }

  void _saveExcelFile(
    List<List<CellValue>> rows,
    BuildContext context,
  ) {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    for (final key in AnalyticsSummaryEnum.values) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              rowIndex: 0,
              columnIndex: key.index,
            ),
          )
          .value = TextCellValue(key.header(L10n.of(context)));
    }

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      for (int j = 0; j < row.length; j++) {
        final cell = row[j];
        sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: i + 2, columnIndex: j))
            .value = cell;
      }
    }
    excel.save();
  }
}
