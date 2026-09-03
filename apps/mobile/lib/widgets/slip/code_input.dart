import 'package:flutter/material.dart';

import '../../design/widgets/app_button.dart';
import '../../design/widgets/app_input.dart';

/// The entry point of the whole product: paste a code, decode it.
class CodeInput extends StatelessWidget {
  const CodeInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onChanged,
    this.error,
    this.loading = false,
    this.label = 'Booking code',
    this.hint = 'BW + 8 characters, e.g. BW6E19810C',
    this.cta = 'Decode code',
    this.onPaste,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String>? onChanged;
  final String? error;
  final bool loading;
  final String label;
  final String hint;
  final String cta;
  final VoidCallback? onPaste;

  // Matches `apps/api`'s own validation exactly (`bookingCode` in
  // `booking-codes.schema.ts`: `^BW[0-9A-F]{8}$`, hex digits only). A looser
  // client-side gate would let something like `BWZZZZZZZZ` through to the
  // server, which rejects it as a `400 invalid_request` — a different,
  // more confusing failure than the `404 invalid_code` this input is meant
  // to gate for.
  static final _codePattern = RegExp(r'^BW[0-9A-F]{8}$');

  bool get _ready =>
      _codePattern.hasMatch(controller.text.trim().toUpperCase());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppInput(
            controller: controller,
            label: label,
            mono: true,
            uppercase: true,
            maxLength: 10,
            icon: 'hash',
            placeholder: 'BW6E19810C',
            onChanged: onChanged,
            onSubmitted: (v) {
              if (_ready) onSubmit(v);
            },
            hint: hint,
            error: error,
            suffix: onPaste != null
                ? AppButton(
                    label: 'Paste',
                    variant: AppButtonVariant.ghost,
                    size: AppButtonSize.sm,
                    onPressed: onPaste,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: cta,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.lg,
            fullWidth: true,
            icon: 'scan-line',
            loading: loading,
            disabled: !_ready,
            onPressed: () => onSubmit(controller.text),
          ),
        ],
      ),
    );
  }
}
