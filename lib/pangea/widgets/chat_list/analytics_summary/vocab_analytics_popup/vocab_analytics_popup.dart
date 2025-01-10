import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/pangea/constants/analytics_constants.dart';
import 'package:fluffychat/pangea/enum/construct_type_enum.dart';
import 'package:fluffychat/pangea/enum/lemma_category_enum.dart';
import 'package:fluffychat/pangea/enum/progress_indicators_enum.dart';
import 'package:fluffychat/pangea/models/analytics/construct_list_model.dart';
import 'package:fluffychat/pangea/models/analytics/construct_use_model.dart';
import 'package:fluffychat/pangea/widgets/chat_list/analytics_summary/vocab_analytics_popup/vocab_definition_popup.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class VocabAnalyticsPopup extends StatefulWidget {
  const VocabAnalyticsPopup({
    super.key,
  });

  @override
  VocabAnalyticsPopupState createState() => VocabAnalyticsPopupState();
}

class VocabAnalyticsPopupState extends State<VocabAnalyticsPopup> {
  ConstructListModel get _constructsModel =>
      MatrixState.pangeaController.getAnalytics.constructListModel;

  List<ConstructUses> get _sortedEntries {
    final entries =
        _constructsModel.constructList(type: ConstructTypeEnum.vocab);
    entries.sort((a, b) => b.points.compareTo(a.points));
    return entries;
  }

  /// Produces list of chips with lemma content,
  /// and assigns them to flowers, greens, and seeds tiles
  Widget get dialogContent {
    if (_constructsModel.constructList(type: ConstructTypeEnum.vocab).isEmpty) {
      return Center(child: Text(L10n.of(context).noDataFound));
    }

    // Get lists of lemmas
    final List<Widget> flowerLemmas = [];
    final List<Widget> greenLemmas = [];
    final List<Widget> seedLemmas = [];
    for (int i = 0; i < _sortedEntries.length; i++) {
      final construct = _sortedEntries[i];
      final int points = construct.points;

      // Add lemma to relevant widget list, followed by comma
      if (points < AnalyticsConstants.xpForGreens) {
        seedLemmas.add(
          VocabChip(
            construct: construct,
            onTap: () {
              showDialog<VocabDefinitionPopup>(
                context: context,
                builder: (c) => VocabDefinitionPopup(
                  construct: construct,
                  type: LemmaCategoryEnum.seeds,
                  points: points,
                ),
              );
            },
          ),
        );
        seedLemmas.add(
          const Text(
            ", ",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        );
      } else if (points >= AnalyticsConstants.xpForFlower) {
        flowerLemmas.add(
          VocabChip(
            construct: construct,
            onTap: () {
              showDialog<VocabDefinitionPopup>(
                context: context,
                builder: (c) => VocabDefinitionPopup(
                  construct: construct,
                  type: LemmaCategoryEnum.flowers,
                  points: points,
                ),
              );
            },
          ),
        );
        flowerLemmas.add(
          const Text(
            ", ",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        );
      } else {
        greenLemmas.add(
          VocabChip(
            construct: construct,
            onTap: () {
              showDialog<VocabDefinitionPopup>(
                context: context,
                builder: (c) => VocabDefinitionPopup(
                  construct: construct,
                  type: LemmaCategoryEnum.greens,
                  points: points,
                ),
              );
            },
          ),
        );
        greenLemmas.add(
          const Text(
            ", ",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        );
      }
    }

    // Pass sorted lemmas to background widgets
    final Widget flowers =
        dialogWidget(LemmaCategoryEnum.flowers, flowerLemmas);
    final Widget greens = dialogWidget(LemmaCategoryEnum.greens, greenLemmas);
    final Widget seeds = dialogWidget(LemmaCategoryEnum.seeds, seedLemmas);

    return ListView(
      children: [flowers, greens, seeds],
    );
  }

  /// Card that contains flowers, greens, and seeds chips
  Widget dialogWidget(LemmaCategoryEnum type, List<Widget> lemmaList) {
    // Remove extraneous commas from lemmaList
    if (lemmaList.isNotEmpty) {
      lemmaList.removeLast();
    } else {
      lemmaList.add(
        const Text(
          "No lemmas",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Material(
        borderRadius:
            const BorderRadius.all(Radius.circular(AppConfig.borderRadius)),
        color: type.color,
        child: Padding(
          padding: const EdgeInsets.all(
            10,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                    radius: 16,
                    child: Text(
                      " ${type.emoji}",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    " ${type.xpString} XP",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Wrap(
                spacing: 0,
                runSpacing: 0,
                children: lemmaList,
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Scaffold(
            appBar: AppBar(
              title: Text(ProgressIndicatorEnum.wordsUsed.tooltip(context)),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: Navigator.of(context).pop,
              ),
              // Edit: add search and training buttons
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: dialogContent,
            ),
          ),
        ),
      ),
    );
  }
}

// a simple chip with the text of the lemma
// highlights on hover
// callback on click
// has some padding to separate from other chips
// otherwise, is very visually simple with transparent border/background/etc
class VocabChip extends StatelessWidget {
  final ConstructUses construct;
  final VoidCallback onTap;

  const VocabChip({
    super.key,
    required this.construct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        construct.lemma,
        style: const TextStyle(
          // Workaround to add space between text and underline
          color: Colors.transparent,
          shadows: [
            Shadow(
              color: Colors.black,
              offset: Offset(0, -3),
            ),
          ],
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dashed,
          decorationColor: Colors.black,
          decorationThickness: 1,
          fontSize: 15,
        ),
      ),
    );
  }
}