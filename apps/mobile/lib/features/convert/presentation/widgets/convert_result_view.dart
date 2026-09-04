import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../models/convert_result.dart';
import '../../../../widgets/slip/slip_card.dart';

/// Betway's own site — the fallback `decode_screen.dart` and
/// `created_code_view.dart` use, for the same reason: no verified deep link.
const _betwayUrl = 'https://www.betway.com.ng';

/// The after view: the new code as a [SlipCard], with the before/after diff in
/// the card's notice slot. The selections and total are the **decoded new
/// code** (`docs/backend-api.md` §1) — `previousTotalOdds` is the only "before"
/// number, since the new odds are re-encoded and drift from the old slip.
class ConvertResultView extends StatefulWidget {
  const ConvertResultView({
    super.key,
    required this.result,
    required this.onConvertAnother,
  });

  final ConvertResult result;
  final VoidCallback onConvertAnother;

  @override
  State<ConvertResultView> createState() => _ConvertResultViewState();
}

class _ConvertResultViewState extends State<ConvertResultView> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.result.bookingCode));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _openBetway() async {
    // `launchUrl` throws when nothing can handle the URI; surface a line
    // instead of an unhandled error.
    try {
      final ok = await launchUrl(
        Uri.parse(_betwayUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && mounted) _toast();
    } on Exception {
      if (mounted) _toast();
    }
  }

  void _toast() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Couldn't open Betway.")));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final legWord = r.selections.length == 1 ? 'leg' : 'legs';
    final droppedWord = r.droppedCount == 1 ? 'leg' : 'legs';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Text(
          'CONVERTED',
          style: AppTypography.label.copyWith(color: context.colors.accentText),
        ),
        const SizedBox(height: 10),
        SlipCard(
          code: r.bookingCode,
          totalOdds: r.totalOdds,
          selections: r.selections,
          collapsedCount: 5,
          onCopy: _copy,
          notice: _Diff(result: r, legWord: legWord, droppedWord: droppedWord),
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Open in Betway',
                      variant: AppButtonVariant.primary,
                      icon: 'external-link',
                      onPressed: _openBetway,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    label: _copied ? 'Copied' : 'Copy',
                    variant: AppButtonVariant.secondary,
                    icon: _copied ? 'check' : 'copy',
                    onPressed: _copy,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Convert another code',
                variant: AppButtonVariant.ghost,
                icon: 'repeat',
                fullWidth: true,
                onPressed: widget.onConvertAnother,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Diff extends StatelessWidget {
  const _Diff({
    required this.result,
    required this.legWord,
    required this.droppedWord,
  });

  final ConvertResult result;
  final String legWord;
  final String droppedWord;

  @override
  Widget build(BuildContext context) {
    final r = result;
    return AppAlert(
      tone: AppAlertTone.success,
      icon: 'repeat',
      title: r.droppedCount == 0
          ? 'Reissued ${r.previousBookingCode}'
          : 'Dropped ${r.droppedCount} $droppedWord from ${r.previousBookingCode}',
      body:
          'Was ${r.previousTotalOdds.toStringAsFixed(2)} — now '
          '${r.totalOdds.toStringAsFixed(2)} across ${r.selections.length} '
          '$legWord. Odds are re-priced on the new code, so they differ from '
          'the old slip.',
    );
  }
}
