import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di.dart';
import '../design/tokens/app_colors.dart';
import '../design/tokens/app_motion.dart';
import '../design/tokens/app_radius.dart';
import '../design/tokens/app_spacing.dart';
import '../design/tokens/app_typography.dart';
import '../design/widgets/app_tabs.dart';
import '../features/convert/presentation/pages/convert_screen.dart';
import '../features/create/presentation/cubit/create_cubit.dart';
import '../features/create/presentation/cubit/create_state.dart';
import '../features/create/presentation/cubit/events_cubit.dart';
import '../features/create/presentation/pages/create_screen.dart';
import '../features/create/presentation/widgets/draft_bar.dart';
import '../features/decode/presentation/pages/decode_screen.dart';

const _tabItems = [
  AppTabItem(value: 'decode', label: 'Decode', icon: 'scan-line'),
  AppTabItem(value: 'create', label: 'Create', icon: 'plus'),
  AppTabItem(value: 'convert', label: 'Convert', icon: 'repeat'),
];

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

  /// Carried from Decode's "Rebuild" button so Convert opens on that code.
  /// Cleared when the user switches tabs by hand — a manual tap on Convert
  /// starts from a blank input, not whatever Decode last looked at.
  String? _convertCode;

  /// Drives the Create page scroll so generating a code jumps back to the top,
  /// where the recap now sits.
  final _createScroll = ScrollController();

  @override
  void dispose() {
    _createScroll.dispose();
    super.dispose();
  }

  void _setMode(String v) => setState(() {
    _convertCode = null;
    _mode = v;
  });

  void _scrollCreateToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_createScroll.hasClients) {
        _createScroll.animateTo(
          0,
          duration: AppMotion.slow,
          curve: AppMotion.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceApp,
      body: SafeArea(child: _tab()),
    );
  }

  /// Create owns the two screen-level cubits at this level — not inside
  /// `CreateView` — so the floating `DraftBar` in the chrome's overlay reads
  /// the same draft the content does.
  Widget _tab() {
    switch (_mode) {
      case 'create':
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<CreateCubit>()..load()),
            BlocProvider(create: (_) => getIt<EventsCubit>()),
          ],
          child: BlocListener<CreateCubit, CreateState>(
            listenWhen: (prev, curr) =>
                curr is CreateReady &&
                curr.createdCode != null &&
                (prev is! CreateReady || prev.createdCode == null),
            listener: (_, _) => _scrollCreateToTop(),
            child: _ShellChrome(
              mode: _mode,
              onModeChanged: _setMode,
              scrollController: _createScroll,
              floatingFooter: const DraftBar(),
              body: const CreateView(),
            ),
          ),
        );
      case 'convert':
        return _ShellChrome(
          mode: _mode,
          onModeChanged: _setMode,
          body: ConvertScreen(
            key: ValueKey(_convertCode),
            initialCode: _convertCode,
          ),
        );
      default:
        return _ShellChrome(
          mode: _mode,
          onModeChanged: _setMode,
          body: DecodeScreen(
            onConvert: (code) => setState(() {
              _convertCode = code;
              _mode = 'convert';
            }),
          ),
        );
    }
  }
}

/// The wordmark + mode tabs + a screen, in one page scroll (the web's
/// `min-h-dvh` column). [floatingFooter], when given, is pinned over the
/// bottom of the viewport rather than scrolling with the content.
class _ShellChrome extends StatelessWidget {
  const _ShellChrome({
    required this.mode,
    required this.onModeChanged,
    required this.body,
    this.floatingFooter,
    this.scrollController,
  });

  final String mode;
  final ValueChanged<String> onModeChanged;
  final Widget body;
  final Widget? floatingFooter;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Align(alignment: Alignment.centerLeft, child: _Wordmark()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AppTabs(
              value: mode,
              onChanged: onModeChanged,
              items: _tabItems,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutterMobile,
              0,
              AppSpacing.gutterMobile,
              24,
            ),
            child: body,
          ),
        ],
      ),
    );

    if (floatingFooter == null) return scroll;
    return Stack(
      children: [
        Positioned.fill(child: scroll),
        Positioned(left: 0, right: 0, bottom: 0, child: floatingFooter!),
      ],
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
