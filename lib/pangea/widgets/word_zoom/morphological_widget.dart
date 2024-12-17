import 'dart:developer';

import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class MorphologicalWidget extends StatefulWidget {
  final PangeaToken token;
  final String morphFeature;

  const MorphologicalWidget({
    super.key,
    required this.token,
    required this.morphFeature,
  });

  @override
  _MorphologicalWidgetState createState() => _MorphologicalWidgetState();
}

class _MorphologicalWidgetState extends State<MorphologicalWidget> {
  late Future<String> _morphValue;

  @override
  void initState() {
    super.initState();
    _morphValue = _fetchMorphValue();
  }

  Future<String> _fetchMorphValue() async {
    if (widget.token.shouldDoMorphActivity(widget.morphFeature)) {
      return '?';
    } else {
      return widget.token.morph[widget.morphFeature] ?? 'No value found';
    }
  }

  // TODO Maybe move this to a separate file
  IconData get _getIconForMorphFeature {
    // Define a function to get the icon based on the universal dependency morphological feature (key)
    switch (widget.morphFeature) {
      case 'Number':
        // google material 123 icon
        return Icons.format_list_numbered;
      case 'Gender':
        return Icons.wc;
      case 'Tense':
        return Icons.access_time;
      case 'Mood':
        return Icons.mood;
      case 'Person':
        return Icons.person;
      case 'Case':
        return Icons.format_list_bulleted;
      case 'Degree':
        return Icons.trending_up;
      case 'VerbForm':
        return Icons.text_format;
      case 'Voice':
        return Icons.record_voice_over;
      case 'Aspect':
        return Icons.aspect_ratio;
      case 'PronType':
        return Icons.text_fields;
      case 'NumType':
        return Icons.format_list_numbered;
      case 'Poss':
        return Icons.account_balance;
      case 'Reflex':
        return Icons.refresh;
      case 'Foreign':
        return Icons.language;
      case 'Abbr':
        return Icons.text_format;
      case 'NounType':
        return Symbols.abc;
      default:
        debugger(when: kDebugMode);
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _morphValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ActionChip(
            avatar: Icon(_getIconForMorphFeature),
            label: Text(snapshot.data ?? 'No value found'),
            onPressed: () {
              // Handle chip click
            },
          );
        }
      },
    );
  }
}
