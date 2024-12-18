import 'package:fluffychat/config/themes.dart';
import 'package:fluffychat/pangea/widgets/pressable_button.dart';
import 'package:flutter/material.dart';

class FullWidthButton extends StatefulWidget {
  final Widget title;
  final void Function()? onPressed;
  final bool depressed;
  final String? error;
  final bool loading;
  final bool enabled;

  const FullWidthButton({
    required this.title,
    required this.onPressed,
    this.depressed = false,
    this.error,
    this.loading = false,
    this.enabled = true,
    super.key,
  });

  @override
  FullWidthButtonState createState() => FullWidthButtonState();
}

class FullWidthButtonState extends State<FullWidthButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 4, widget.error == null ? 4 : 0),
          child: AnimatedOpacity(
            duration: FluffyThemes.animationDuration,
            opacity: widget.enabled ? 1 : 0.5,
            child: PressableButton(
              depressed: widget.depressed || !widget.enabled,
              onPressed: widget.onPressed,
              borderRadius: BorderRadius.circular(36),
              color: Theme.of(context).colorScheme.primary,
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.enabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      disabledForegroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    onPressed: widget.enabled
                        ? () => ButtonPressedNotification().dispatch(context)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.loading
                            ? const Expanded(child: LinearProgressIndicator())
                            : widget.title,
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: FluffyThemes.animationDuration,
          child: widget.error == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 5,
                  ),
                  child: Text(
                    widget.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class FullWidthTextField extends StatelessWidget {
  final String hintText;
  final bool autocorrect;
  final bool autofocus;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String? errorText;

  const FullWidthTextField({
    required this.hintText,
    this.autocorrect = false,
    this.autofocus = false,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.controller,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: TextFormField(
        obscureText: obscureText,
        autocorrect: autocorrect,
        autofocus: autofocus,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(36.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          errorText: errorText,
        ),
        validator: validator,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        controller: controller,
      ),
    );
  }
}
