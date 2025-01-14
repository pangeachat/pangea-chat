import 'package:fluffychat/pangea/models/pangea_token_model.dart';
import 'package:flutter/material.dart';

class LemmaWidget extends StatelessWidget {
  final PangeaToken token;

  const LemmaWidget({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text("${token.lemma.text} ${token.xpEmoji}"),
    );
  }
}
