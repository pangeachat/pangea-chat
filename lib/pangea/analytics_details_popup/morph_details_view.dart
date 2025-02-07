import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import 'package:fluffychat/pangea/analytics_details_popup/analytics_details_popup_content.dart';
import 'package:fluffychat/pangea/analytics_misc/construct_identifier.dart';
import 'package:fluffychat/pangea/analytics_misc/construct_level_enum.dart';
import 'package:fluffychat/pangea/analytics_misc/construct_type_enum.dart';
import 'package:fluffychat/pangea/analytics_misc/construct_use_model.dart';
import 'package:fluffychat/pangea/morphs/get_grammar_copy.dart';
import 'package:fluffychat/pangea/morphs/morph_icon.dart';

class MorphDetailsView extends StatelessWidget {
  final ConstructIdentifier constructId;

  const MorphDetailsView({
    required this.constructId,
    super.key,
  });

  ConstructUses get construct => constructId.constructUses;
  String get morphFeature => constructId.category;
  String get morphTag => constructId.lemma;

  String _categoryCopy(
    BuildContext context,
  ) {
    if (morphFeature.toLowerCase() == "other") {
      return L10n.of(context).other;
    }

    return ConstructTypeEnum.morph.getDisplayCopy(
          morphFeature,
          context,
        ) ??
        morphFeature;
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).brightness != Brightness.light
        ? construct.lemmaCategory.color
        : construct.lemmaCategory.darkColor;

    return AnalyticsDetailsViewContent(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32.0,
            height: 32.0,
            child: MorphIcon(
              morphFeature: morphFeature,
              morphTag: morphTag,
            ),
          ),
          const SizedBox(width: 10.0),
          Text(
            getGrammarCopy(
                  category: morphFeature,
                  lemma: morphTag,
                  context: context,
                ) ??
                morphTag,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.0,
            height: 24.0,
            child: MorphIcon(morphFeature: morphFeature, morphTag: null),
          ),
          const SizedBox(width: 10.0),
          Text(
            _categoryCopy(context),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                ),
          ),
        ],
      ),
      headerContent: const SizedBox(),
      xpIcon: CircleAvatar(
        radius: 16.0,
        backgroundColor: construct.lemmaCategory.color,
        child: const Icon(
          Icons.star,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      constructId: constructId,
    );
  }
}
