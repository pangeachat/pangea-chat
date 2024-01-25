import 'dart:developer';

import 'package:fluffychat/pangea/widgets/igc/span_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../choreographer/controllers/choreographer.dart';
import '../../enum/edit_type.dart';
import '../../models/span_card_model.dart';
import '../../models/widget_measurement.dart';
import '../../utils/overlay.dart';

class PangeaTextController extends TextEditingController {
  Choreographer choreographer;

  EditType editType = EditType.keyboard;
  WidgetMeasurements? measurements;
  PangeaTextController({
    String? text,
    required this.choreographer,
  }) {
    text ??= '';
    this.text = text;
  }
  bool forceKeepOpen = false;

  setSystemText(String text, EditType type) {
    editType = type;
    this.text = text;
  }

  void onBarSizeChange(Size? size, Offset? position, String? uid) {
    measurements = WidgetMeasurements(position: position, size: size, uid: uid);
  }

  void onInputTap(BuildContext context, {required FocusNode fNode}) {
    fNode.requestFocus();
    forceKeepOpen = true;
    if (!context.mounted) {
      debugger(when: kDebugMode);
      return;
    }
    if (choreographer.igc.igcTextData == null) return;

    // debugPrint(
    //     "onInputTap matches are ${choreographer.igc.igcTextData?.matches.map((e) => e.match.rule.id).toList().toString()}");

    final int tokenIndex = choreographer.igc.igcTextData!.tokenIndexByOffset(
      selection.baseOffset,
    );

    if (tokenIndex == -1) return;

    final int matchIndex =
        choreographer.igc.igcTextData!.getTopMatchIndexForOffset(
      selection.baseOffset,
    );
    final Widget? cardToShow = matchIndex != -1
        ? SpanCard(
            scm: SpanCardModel(
              // igcTextData: choreographer.igc.igcTextData!,
              matchIndex: matchIndex,
              onReplacementSelect: choreographer.onReplacementSelect,
              // may not need this
              onSentenceRewrite: ((sentenceRewrite) async {
                debugPrint("onSentenceRewrite $tokenIndex $sentenceRewrite");
              }),
              onIgnore: () => choreographer.onIgnoreMatch(
                cursorOffset: selection.baseOffset,
              ),
              onITStart: () {
                choreographer.onITStart(
                  choreographer.igc.igcTextData!.matches[matchIndex],
                );
              },
              choreographer: choreographer,
            ),
            roomId: choreographer.roomId,
          )
        : null;

    if (cardToShow != null) {
      OverlayUtil.showPositionedCard(
        context: context,
        cardSize: matchIndex != -1 &&
                choreographer.igc.igcTextData!.matches[matchIndex].isITStart
            ? const Size(350, 220)
            : const Size(350, 400),
        cardToShow: cardToShow,
        transformTargetId: choreographer.inputTransformTargetKey,
      );
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // If the composing range is out of range for the current text, ignore it to
    // preserve the tree integrity, otherwise in release mode a RangeError will
    // be thrown and this EditableText will be built with a broken subtree.
    // debugPrint("composing? $withComposing");
    // if (!value.isComposingRangeValid || !withComposing) {
    //   debugPrint("just returning straight text");
    //   // debugger(when: kDebugMode);
    //   return TextSpan(style: style, text: text);
    // }
    // if (value.isComposingRangeValid) {
    //   debugPrint("composing before ${value.composing.textBefore(value.text)}");
    //   debugPrint("composing inside ${value.composing.textInside(value.text)}");
    //   debugPrint("composing after ${value.composing.textAfter(value.text)}");
    // }

    if (choreographer.igc.igcTextData == null || text.isEmpty) {
      return TextSpan(text: text, style: style);
    } else {
      final parts = text.split(choreographer.igc.igcTextData!.originalInput);

      if (parts.length == 1 || parts.length > 2) {
        return TextSpan(text: text, style: style);
      }

      return TextSpan(
        style: style,
        children: [
          ...choreographer.igc.igcTextData!.constructTokenSpan(
            context: context,
            defaultStyle: style,
            spanCardModel: null,
            handleClick: false,
            transformTargetId: choreographer.inputTransformTargetKey,
            room: choreographer.chatController.room,
          ),
          TextSpan(text: parts[1], style: style),
        ],
      );
    }
  }
}
