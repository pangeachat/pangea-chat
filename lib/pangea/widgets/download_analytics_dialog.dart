import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/constants/class_default_values.dart';
import 'package:fluffychat/pangea/enum/analytics/analytics_summary_enum.dart';
import 'package:fluffychat/pangea/extensions/pangea_room_extension/pangea_room_extension.dart';
import 'package:fluffychat/pangea/models/analytics/analytics_summary_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/models/analytics/constructs_model.dart';
import 'package:fluffychat/pangea/utils/bot_name.dart';
import 'package:fluffychat/pangea/utils/download_file.dart';
import 'package:fluffychat/pangea/utils/grammar/get_grammar_copy.dart';
import 'package:fluffychat/widgets/matrix.dart';

class DownloadAnalyticsDialog extends StatefulWidget {
  final Room space;
  const DownloadAnalyticsDialog({
    required this.space,
    super.key,
  });

  @override
  DownloadAnalyticsDialogState createState() => DownloadAnalyticsDialogState();
}

class DownloadAnalyticsDialogState extends State<DownloadAnalyticsDialog> {
  bool _loading = true;
  String? _error;
  Map<String, int> _downloadStatues = {};

  @override
  void initState() {
    super.initState();
    widget.space.requestParticipants().whenComplete(() {
      _downloadStatues = Map.fromEntries(
        _usersToDownload.map((user) => MapEntry(user.id, 0)),
      );
      if (mounted) setState(() => _loading = false);
    }).catchError((error) {
      if (mounted) setState(() => _error = error.toString());
      return <User>[];
    });
  }

  List<User> get _usersToDownload => widget.space
      .getParticipants()
      .where(
        (member) =>
            widget.space.getPowerLevelByUserId(member.id) <
                ClassDefaultValues.powerLevelOfAdmin &&
            member.id != BotName.byEnvironment,
      )
      .toList();

  Color _downloadStatusColor(String userID) {
    final status = _downloadStatues[userID];
    if (status == 1) return Colors.yellow;
    if (status == 2) return Colors.green;
    if (status == -1) return Colors.red;
    return Colors.grey;
  }

  Room? _userAnalyticsRoom(String userID) {
    final rooms = widget.space.client.rooms;
    final l2 = MatrixState.pangeaController.languageController.userL2?.langCode;
    if (l2 == null) return null;
    return rooms.firstWhereOrNull((room) {
      return room.isAnalyticsRoomOfUser(userID) && room.isMadeForLang(l2);
    });
  }

  Future<void> _runDownload() async {
    try {
      _loading = true;
      _error = null;
      _downloadStatues = Map.fromEntries(
        _usersToDownload.map((user) => MapEntry(user.id, 1)),
      );
      if (mounted) setState(() {});
      await _downloadSpaceAnalytics();
    } catch (error) {
      _downloadStatues = Map.fromEntries(
        _usersToDownload.map((user) => MapEntry(user.id, 0)),
      );
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadSpaceAnalytics() async {
    final l2 = MatrixState.pangeaController.languageController.userL2?.langCode;
    if (l2 == null) return;

    final List<AnalyticsSummaryModel?> summaries = await Future.wait(
      _usersToDownload.map((user) => _getUserAnalyticsModel(user.id)),
    );

    final allSummaries = summaries.whereType<AnalyticsSummaryModel>().toList();
    final content = _downloadType == DownloadType.xlsx
        ? _getExcelFileContent(allSummaries)
        : _getCSVFileContent(allSummaries);

    final fileName =
        "analytics_${widget.space.name}_${DateTime.now().toIso8601String()}.${_downloadType == DownloadType.xlsx ? 'xlsx' : 'csv'}";

    await downloadFile(
      content,
      fileName,
      DownloadType.csv,
    );
  }

  Future<AnalyticsSummaryModel?> _getUserAnalyticsModel(String userID) async {
    setState(() => _downloadStatues[userID] = 1);
    final userAnalyticsRoom = _userAnalyticsRoom(userID);
    final constructEvents = await userAnalyticsRoom?.getAnalyticsEvents(
      userId: userID,
    );
    if (constructEvents == null) {
      setState(() => _downloadStatues[userID] = 0);
      return null;
    }

    try {
      final List<OneConstructUse> uses = [];
      for (final event in constructEvents) {
        uses.addAll(event.content.uses);
      }

      final constructs = ConstructListModel(uses: uses);
      final summary = AnalyticsSummaryModel.fromConstructListModel(
        constructs,
        userID,
        getCopy,
        context,
      );
      setState(() => _downloadStatues[userID] = 2);
      return summary;
    } catch (err) {
      setState(() => _downloadStatues[userID] = -1);
    }
    return null;
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

  List<int> _getExcelFileContent(
    List<AnalyticsSummaryModel> summaries,
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

    final rows = summaries.map((summary) => _formatExcelRow(summary)).toList();

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      for (int j = 0; j < row.length; j++) {
        final cell = row[j];
        sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: i + 2, columnIndex: j))
            .value = cell;
      }
    }
    return excel.encode() ?? [];
  }

  String _getCSVFileContent(
    List<AnalyticsSummaryModel> summaries,
  ) {
    final List<List<dynamic>> rows = [];
    final headerRow = [];
    for (final key in AnalyticsSummaryEnum.values) {
      headerRow.add(key.header(L10n.of(context)));
    }
    rows.add(headerRow);

    for (final summary in summaries) {
      final row = [];
      for (int i = 0; i < AnalyticsSummaryEnum.values.length; i++) {
        final key = AnalyticsSummaryEnum.values[i];
        final value = summary.getValue(key);
        value is List<String> ? row.add(value.join(", ")) : row.add(value);
      }
      rows.add(row);
    }

    final String fileString = const ListToCsvConverter().convert(rows);
    return fileString;
  }

  String getCopy(ConstructUses use) {
    return getGrammarCopy(
          category: use.category,
          lemma: use.lemma,
          context: context,
        ) ??
        use.lemma;
  }

  DownloadType _downloadType = DownloadType.csv;

  void _setDownloadType(DownloadType type) =>
      setState(() => _downloadType = type);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 350,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L10n.of(context).fileType,
              style: TextStyle(
                fontSize: AppConfig.fontSizeFactor * AppConfig.messageFontSize,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SegmentedButton<DownloadType>(
                selected: {_downloadType},
                onSelectionChanged: (c) => _setDownloadType(c.first),
                segments: [
                  ButtonSegment(
                    value: DownloadType.csv,
                    label: Text(L10n.of(context).commaSeparatedFile),
                  ),
                  ButtonSegment(
                    value: DownloadType.xlsx,
                    label: Text(L10n.of(context).excelFile),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  itemCount: _usersToDownload.length,
                  itemBuilder: (context, index) {
                    final user = _usersToDownload[index];
                    final analyticsAvailable =
                        _userAnalyticsRoom(user.id) != null;
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Tooltip(
                        message: analyticsAvailable
                            ? ""
                            : L10n.of(context).analyticsNotAvailable,
                        child: Opacity(
                          opacity: analyticsAvailable ? 1 : 0.5,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: !analyticsAvailable
                                    ? const Icon(
                                        Icons.error_outline,
                                        size: 16,
                                      )
                                    : CircleAvatar(
                                        backgroundColor:
                                            _downloadStatusColor(user.id),
                                        radius: 6,
                                      ),
                              ),
                              Text(user.displayName ?? user.id),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: OutlinedButton(
                onPressed: _loading ? null : _runDownload,
                child: _loading
                    ? const CircularProgressIndicator.adaptive()
                    : Text(L10n.of(context).download),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(L10n.of(context).oopsSomethingWentWrong),
              ),
          ],
        ),
      ),
    );
  }
}
