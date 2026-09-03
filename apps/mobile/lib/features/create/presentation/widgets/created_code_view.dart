import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../widgets/slip/slip_card.dart';
import '../cubit/create_state.dart';

/// Betway's own site — the same fallback `decode_screen.dart` uses, for the
/// same reason: no verified deep-link format for a specific code.
const _betwayUrl = 'https://www.betway.com.ng';

/// Shown once a code exists. Reuses [SlipCard] — the recap is the legs the
/// user picked, rendered exactly as a decoded slip would be. The odds are
/// what we held at pick time, not a re-decode of the new code: `POST
/// /api/booking-codes` returns only the string, and prices drift between pick
/// and encode (`docs/betway-api.md` §3), so the caveat says so plainly rather
/// than showing a total the code may not actually have.
class CreatedCodeView extends StatefulWidget {
  const CreatedCodeView({
    super.key,
    required this.state,
    required this.onStartOver,
  });

  final CreateReady state;
  final VoidCallback onStartOver;

  @override
  State<CreatedCodeView> createState() => _CreatedCodeViewState();
}

class _CreatedCodeViewState extends State<CreatedCodeView> {
  bool _copied = false;

  Future<void> _copy() async {
    final code = widget.state.createdCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
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
    final state = widget.state;
    final code = state.createdCode!;
    final selections = state.picks
        .map((p) => p.toSelection())
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        const SizedBox(height: 4),
        Text(
          'CODE CREATED',
          style: AppTypography.label.copyWith(color: context.colors.accentText),
        ),
        const SizedBox(height: 10),
        SlipCard(
          code: code,
          totalOdds: state.totalOdds,
          selections: selections,
          collapsedCount: 5,
          onCopy: _copy,
          notice: const AppAlert(
            tone: AppAlertTone.info,
            title: 'Odds are from when you picked',
            body:
                'Betway prices move continuously. The code is live — the exact '
                'odds may have shifted since you built this slip.',
          ),
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
                label: 'Build another slip',
                variant: AppButtonVariant.ghost,
                icon: 'plus',
                fullWidth: true,
                onPressed: widget.onStartOver,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
