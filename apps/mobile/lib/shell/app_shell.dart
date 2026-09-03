import 'package:flutter/material.dart';

import '../design/tokens/app_colors.dart';
import '../design/tokens/app_radius.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../design/widgets/app_tabs.dart';
import '../features/convert/presentation/pages/convert_screen.dart';
import '../features/create/presentation/pages/create_screen.dart';
import '../features/decode/presentation/pages/decode_screen.dart';

/// Header, mode [AppTabs] and body, ported from `ui_kits/mobile/app-shell.jsx`.
/// The phone's own status bar replaces the JSX kit's drawn-on-canvas one
/// (that existed only because the web artboard has no real device chrome);
/// everything below it is unchanged.
///
/// The source header's `History`/`Settings` icons and its bottom nav
/// (`Codes`/`Saved`/`You`) are cut for v1 — none of the three destinations
/// beyond Decode/Create/Convert exist, and there is nothing else in the app
/// for those icons to do yet.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _mode = 'decode';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surfaceApp,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Align(alignment: Alignment.centerLeft, child: _Wordmark()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppTabs(
                value: _mode,
                onChanged: (v) => setState(() => _mode = v),
                items: const [
                  AppTabItem(
                    value: 'decode',
                    label: 'Decode',
                    icon: 'scan-line',
                  ),
                  AppTabItem(value: 'create', label: 'Create', icon: 'plus'),
                  AppTabItem(
                    value: 'convert',
                    label: 'Convert',
                    icon: 'repeat',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutterMobile,
                ),
                child: switch (_mode) {
                  'create' => const CreateScreen(),
                  'convert' => const ConvertScreen(),
                  _ => DecodeScreen(
                    onConvert: () => setState(() => _mode = 'convert'),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accentSolid,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            'BC',
            style: AppTypography.code.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1,
              color: colors.textOnAccent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            style: AppTypography.h2.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.03 * 18,
              color: colors.textPrimary,
            ),
            children: [
              const TextSpan(text: 'booking'),
              TextSpan(
                text: 'code',
                style: TextStyle(color: colors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
