import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_icons.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_motion.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

enum AppInputSize { sm, md, lg }

/// Text field. `mono: true, uppercase: true` is the booking-code preset
/// (`CodeInput` composes exactly that).
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.placeholder,
    this.label,
    this.hint,
    this.error,
    this.icon,
    this.suffix,
    this.mono = false,
    this.uppercase = false,
    this.size = AppInputSize.lg,
    this.maxLength,
    this.disabled = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final String? label;
  final String? hint;
  final String? error;
  final String? icon;
  final Widget? suffix;
  final bool mono;
  final bool uppercase;
  final AppInputSize size;
  final int? maxLength;
  final bool disabled;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = switch (widget.size) {
      AppInputSize.sm => 36.0,
      AppInputSize.md => 44.0,
      AppInputSize.lg => 52.0,
    };
    final invalid = widget.error != null;
    final borderColor = invalid
        ? colors.dangerSolid
        : _focused
        ? colors.accentSolid
        : colors.borderInput;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: AppTypography.label.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.easeOut,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surfaceInput,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor),
          ),
          child: Opacity(
            opacity: widget.disabled ? 0.5 : 1,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  AppIcon(widget.icon!, size: 16, color: colors.textMuted),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: !widget.disabled,
                    maxLength: widget.maxLength,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    textCapitalization: widget.uppercase
                        ? TextCapitalization.characters
                        : TextCapitalization.none,
                    autocorrect: false,
                    inputFormatters: widget.uppercase
                        ? [UpperCaseTextFormatter()]
                        : null,
                    style:
                        (widget.mono
                                ? AppTypography.codeHero.copyWith(fontSize: 18)
                                : AppTypography.body)
                            .copyWith(
                              color: widget.mono
                                  ? colors.codeText
                                  : colors.textPrimary,
                            ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      counterText: '',
                      border: InputBorder.none,
                      hintText: widget.placeholder,
                      hintStyle:
                          (widget.mono
                                  ? AppTypography.codeHero.copyWith(
                                      fontSize: 18,
                                    )
                                  : AppTypography.body)
                              .copyWith(color: colors.textDisabled),
                    ),
                  ),
                ),
                if (widget.suffix != null) widget.suffix!,
              ],
            ),
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon('triangle-alert', size: 13, color: colors.dangerText),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.error!,
                  style: AppTypography.meta.copyWith(color: colors.dangerText),
                ),
              ),
            ],
          ),
        ] else if (widget.hint != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.hint!,
            style: AppTypography.meta.copyWith(color: colors.textMuted),
          ),
        ],
      ],
    );
  }
}

/// `textTransform: uppercase` on an editable field also has to transform the
/// stored value, not just the paint — otherwise the model holds lowercase
/// text the user never sees. Mirrors `Input.jsx`'s
/// `onChange(uppercase ? e.target.value.toUpperCase() : ...)`.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
