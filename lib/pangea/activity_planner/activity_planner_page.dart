import 'dart:math';

import 'package:flutter/material.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';

import 'package:fluffychat/pangea/activity_planner/activity_list_view.dart';
import 'package:fluffychat/pangea/activity_planner/activity_mode_list_repo.dart';
import 'package:fluffychat/pangea/activity_planner/activity_plan_request.dart';
import 'package:fluffychat/pangea/activity_planner/learning_objective_list_repo.dart';
import 'package:fluffychat/pangea/activity_planner/list_request_schema.dart';
import 'package:fluffychat/pangea/activity_planner/media_enum.dart';
import 'package:fluffychat/pangea/activity_planner/suggestion_form_field.dart';
import 'package:fluffychat/pangea/activity_planner/topic_list_repo.dart';
import 'package:fluffychat/pangea/chat_settings/widgets/language_level_dropdown.dart';
import 'package:fluffychat/pangea/instructions/instructions_enum.dart';
import 'package:fluffychat/pangea/instructions/instructions_inline_tooltip.dart';
import 'package:fluffychat/pangea/learning_settings/constants/language_constants.dart';
import 'package:fluffychat/pangea/learning_settings/widgets/p_language_dropdown.dart';
import 'package:fluffychat/widgets/matrix.dart';

enum _PageMode {
  settings,
  generatedActivities,
  savedActivities,
}

class ActivityPlannerPage extends StatefulWidget {
  final String roomID;
  const ActivityPlannerPage({super.key, required this.roomID});

  @override
  ActivityPlannerPageState createState() => ActivityPlannerPageState();
}

class ActivityPlannerPageState extends State<ActivityPlannerPage> {
  final _formKey = GlobalKey<FormState>();

  /// Index of the content to display
  _PageMode _pageMode = _PageMode.settings;

  /// Selected values from the form
  String? _selectedTopic;
  String? _selectedMode;
  String? _selectedObjective;
  MediaEnum _selectedMedia = MediaEnum.nan;
  String? _selectedLanguageOfInstructions;
  String? _selectedTargetLanguage;
  int? _selectedCefrLevel;
  int? _selectedNumberOfParticipants;

  List<String> activities = [];

  Room? get room => Matrix.of(context).client.getRoomById(widget.roomID);

  @override
  void initState() {
    super.initState();
    if (room == null) {
      Navigator.of(context).pop();
      return;
    }

    _selectedLanguageOfInstructions =
        MatrixState.pangeaController.languageController.userL1?.langCode;
    _selectedTargetLanguage =
        MatrixState.pangeaController.languageController.userL2?.langCode;
    _selectedCefrLevel = 0;
    _selectedNumberOfParticipants = max(room?.getParticipants().length ?? 1, 1);
  }

  final _topicController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _modeController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    _objectiveController.dispose();
    _modeController.dispose();
    super.dispose();
  }

  ActivitySettingRequestSchema get req => ActivitySettingRequestSchema(
        langCode:
            MatrixState.pangeaController.languageController.userL2?.langCode ??
                LanguageKeys.defaultLanguage,
      );

  Future<List<ActivitySettingResponseSchema>> get _topicItems =>
      TopicListRepo.get(req);

  Future<List<ActivitySettingResponseSchema>> get _modeItems =>
      ActivityModeListRepo.get(req);

  Future<List<ActivitySettingResponseSchema>> get _objectiveItems =>
      LearningObjectiveListRepo.get(req);

  Future<void> _generateActivities() async {
    _pageMode = _PageMode.generatedActivities;
    setState(() {});
  }

  Future<String> _randomTopic() async {
    final topics = await _topicItems;
    return (topics..shuffle()).first.name;
  }

  Future<String> _randomObjective() async {
    final objectives = await _objectiveItems;
    return (objectives..shuffle()).first.name;
  }

  Future<String> _randomMode() async {
    final modes = await _modeItems;
    return (modes..shuffle()).first.name;
  }

  void _randomizeSelections() async {
    _selectedTopic = await _randomTopic();
    _selectedObjective = await _randomObjective();
    _selectedMode = await _randomMode();

    setState(() {
      _topicController.text = _selectedTopic!;
      _objectiveController.text = _selectedObjective!;
      _modeController.text = _selectedMode!;
    });
  }

  // Add validation logic
  String? _validateNotNull(String? value) {
    if (value == null || value.isEmpty) {
      return L10n.of(context).interactiveTranslatorRequired;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _pageMode == _PageMode.settings
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            : IconButton(
                onPressed: () => setState(() => _pageMode = _PageMode.settings),
                icon: const Icon(Icons.arrow_back),
              ),
        title: _pageMode == _PageMode.savedActivities
            ? Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmarks),
                    const SizedBox(width: 8),
                    Text(l10n.myBookmarkedActivities),
                  ],
                ),
              )
            : Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_note_outlined),
                    const SizedBox(width: 8),
                    Text(l10n.activityPlannerTitle),
                  ],
                ),
              ),
        actions: [
          Tooltip(
            message: l10n.myBookmarkedActivities,
            child: IconButton(
              onPressed: () =>
                  setState(() => _pageMode = _PageMode.savedActivities),
              icon: const Icon(Icons.bookmarks),
            ),
          ),
        ],
      ),
      body: _pageMode != _PageMode.settings
          ? ActivityListView(
              room: room,
              activityPlanRequest: _PageMode.savedActivities == _pageMode
                  ? null
                  : ActivityPlanRequest(
                      topic: _selectedTopic!,
                      mode: _selectedMode!,
                      objective: _selectedObjective!,
                      media: _selectedMedia,
                      languageOfInstructions: _selectedLanguageOfInstructions!,
                      targetLanguage: _selectedTargetLanguage!,
                      cefrLevel: _selectedCefrLevel!,
                      numberOfParticipants: _selectedNumberOfParticipants!,
                    ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const InstructionsInlineTooltip(
                        instructionsEnum:
                            InstructionsEnum.activityPlannerOverview,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SuggestionFormField(
                                  suggestions: _topicItems,
                                  validator: _validateNotNull,
                                  label: l10n.topicLabel,
                                  placeholder: l10n.topicPlaceholder,
                                  onSelected: (val) => _selectedTopic = val,
                                  initialValue: _selectedTopic,
                                  controller: _topicController,
                                ),
                                const SizedBox(height: 24),
                                SuggestionFormField(
                                  suggestions: _objectiveItems,
                                  validator: _validateNotNull,
                                  label: l10n.learningObjectiveLabel,
                                  placeholder:
                                      l10n.learningObjectivePlaceholder,
                                  onSelected: (val) => _selectedObjective = val,
                                  initialValue: _selectedObjective,
                                  controller: _objectiveController,
                                ),
                                const SizedBox(height: 24),
                                SuggestionFormField(
                                  suggestions: _modeItems,
                                  validator: _validateNotNull,
                                  label: l10n.modeLabel,
                                  placeholder: l10n.modePlaceholder,
                                  onSelected: (val) => _selectedMode = val,
                                  initialValue: _selectedMode,
                                  controller: _modeController,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shuffle),
                                onPressed: _randomizeSelections,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField2<MediaEnum>(
                        decoration: InputDecoration(labelText: l10n.mediaLabel),
                        items: MediaEnum.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toDisplayCopyUsingL10n(context)),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            _selectedMedia = val ?? MediaEnum.nan,
                        value: _selectedMedia,
                      ),
                      const SizedBox(height: 24),
                      LanguageLevelDropdown(
                        initialLevel: 0,
                        onChanged: (val) => _selectedCefrLevel = val,
                      ),
                      const SizedBox(height: 24),
                      PLanguageDropdown(
                        languages: MatrixState
                            .pangeaController.pLanguageStore.baseOptions,
                        onChange: (val) =>
                            _selectedTargetLanguage = val.langCode,
                        initialLanguage: MatrixState
                            .pangeaController.languageController.userL1,
                        isL2List: false,
                        decorationText:
                            L10n.of(context).languageOfInstructionsLabel,
                      ),
                      const SizedBox(height: 24),
                      PLanguageDropdown(
                        languages: MatrixState
                            .pangeaController.pLanguageStore.targetOptions,
                        onChange: (val) =>
                            _selectedTargetLanguage = val.langCode,
                        initialLanguage: MatrixState
                            .pangeaController.languageController.userL2,
                        decorationText: L10n.of(context).targetLanguageLabel,
                        isL2List: true,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n.numberOfLearners,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.mustBeInteger;
                          }
                          final n = int.tryParse(value);
                          if (n == null || n <= 0) {
                            return l10n.mustBeInteger;
                          }
                          return null;
                        },
                        onChanged: (val) =>
                            _selectedNumberOfParticipants = int.tryParse(val),
                        initialValue: _selectedNumberOfParticipants?.toString(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _generateActivities();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lightbulb_outline),
                            const SizedBox(width: 8),
                            Text(l10n.generateActivitiesButton),
                          ],
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
