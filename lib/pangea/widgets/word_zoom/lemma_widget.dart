import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class LemmaWidget extends StatefulWidget {
  final PangeaToken token;

  const LemmaWidget({super.key, required this.token});

  @override
  _LemmaWidgetState createState() => _LemmaWidgetState();
}

class _LemmaWidgetState extends State<LemmaWidget> {
  late Future<String> _lemmaText;

  @override
  void initState() {
    super.initState();
    _lemmaText = _fetchLemmaText();
  }

  Future<String> _fetchLemmaText() async {
    if (widget.token.shouldDoLemmaActivity) {
      return '?';
    } else {
      return widget.token.lemma.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _lemmaText,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ActionChip(
            avatar: const Icon(Symbols.dictionary),
            label: Text(snapshot.data ?? 'No lemma found'),
            shape: const RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(
                  Radius.circular(8)), // Optional: Adjust radius if needed
            ),
            onPressed: () {
              // Handle chip click
            },
          );
        }
      },
    );
  }
}
