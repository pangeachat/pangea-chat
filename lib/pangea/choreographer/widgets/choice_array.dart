import 'dart:developer';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';

import '../../utils/bot_style.dart';
import 'it_shimmer.dart';

class ChoicesArray extends StatelessWidget {
  final bool isLoading;
  final List<Choice>? choices;
  final void Function(int) onPressed;
  final void Function(int)? onLongPress;
  final int? selectedChoiceIndex;
  final String originalSpan;
  final String Function(int) uniqueKeyForLayerLink;
  const ChoicesArray({
    super.key,
    required this.isLoading,
    required this.choices,
    required this.onPressed,
    required this.originalSpan,
    required this.uniqueKeyForLayerLink,
    required this.selectedChoiceIndex,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return isLoading && (choices == null || choices!.length <= 1)
        ? ItShimmer(originalSpan: originalSpan)
        : Wrap(
            alignment: WrapAlignment.center,
            children: choices
                    ?.asMap()
                    .entries
                    .map(
                      (entry) => ChoiceItem(
                        theme: theme,
                        onLongPress: onLongPress,
                        onPressed: onPressed,
                        entry: entry,
                        isSelected: selectedChoiceIndex == entry.key,
                      ),
                    )
                    .toList() ??
                [],
          );
  }
}

class Choice {
  Choice({
    this.color,
    required this.text,
  });

  final Color? color;
  final String text;
}

class ChoiceItem extends StatelessWidget {
  const ChoiceItem({
    super.key,
    required this.theme,
    required this.onLongPress,
    required this.onPressed,
    required this.entry,
    required this.isSelected,
  });

  final MapEntry<int, Choice> entry;
  final ThemeData theme;
  final void Function(int p1)? onLongPress;
  final void Function(int p1) onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    try {
      return Tooltip(
        message: onLongPress != null ? L10n.of(context)!.holdForInfo : "",
        waitDuration: onLongPress != null
            ? const Duration(milliseconds: 500)
            : const Duration(days: 1),
        child: SelectiveRotatingWidget(
          selected: entry.value.color != null,
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: EdgeInsets.zero,
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: entry.value.color ?? theme.colorScheme.primary,
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                  )
                : null,
            child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 7),
                ),
                //if index is selected, then give the background a slight primary color
                backgroundColor: MaterialStateProperty.all<Color>(
                  entry.value.color != null
                      ? entry.value.color!.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                ),
                textStyle: MaterialStateProperty.all(
                  BotStyle.text(context),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              onLongPress:
                  onLongPress != null ? () => onLongPress!(entry.key) : null,
              onPressed: () => onPressed(entry.key),
              child: Text(
                entry.value.text,
                style: BotStyle.text(context),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugger(when: kDebugMode);
      return Container();
    }
  }
}

class SelectiveRotatingWidget extends StatefulWidget {
  final Widget child;
  final bool selected;

  const SelectiveRotatingWidget({super.key, required this.child, required this.selected});

  @override
  SelectiveRotatingWidgetState createState() => SelectiveRotatingWidgetState();
}

class SelectiveRotatingWidgetState extends State<SelectiveRotatingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: -8 * pi / 180),
        weight: 1.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -8 * pi / 180, end: 16 * pi / 180),
        weight: 2.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 16 * pi / 180, end: 0),
        weight: 1.0,
      ),
    ]).animate(_controller);

    if (widget.selected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SelectiveRotatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
