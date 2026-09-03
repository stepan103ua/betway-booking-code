import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di.dart';
import '../../../../core/failure.dart';
import '../../../../design/app_icons.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_motion.dart';
import '../../../../design/tokens/app_radius.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_badge.dart';
import '../../../../design/widgets/app_bottom_sheet.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../design/widgets/app_skeleton.dart';
import '../../../../design/widgets/dashed_border.dart';
import '../../../../models/slip.dart';
import '../../../../widgets/slip/code_input.dart';
import '../../../../widgets/slip/selection_row.dart';
import '../../../../widgets/slip/slip_card.dart';
import '../../../../widgets/slip/slip_format.dart';
import '../../../../widgets/slip/slip_skeleton.dart';
import '../cubit/popular_codes_cubit.dart';
import '../cubit/popular_codes_state.dart';
import '../cubit/slip_cubit.dart';
import '../cubit/slip_state.dart';

/// Betway's own site — `docs/betway-api.md`'s pinned host. Where "Load in
/// Betway" opens: no deep-link format for a specific code was ever
/// supplied (the design system's own "Known gaps" note says the same about
/// `CodeResult.betwayUrl`), so this takes the user to the site rather than
/// guessing at a URL scheme nothing has verified.
const _betwayUrl = 'https://www.betway.com.ng';

/// Decode: paste a code, see what's inside. Ported from
/// `ui_kits/mobile/decode-screen.jsx`, now wired to the real
/// `POST /api/booking-codes/resolve` via [SlipCubit] — `docs/mobile.md`
/// §3–§7's Clean Architecture / feature-first shape, not fixture data.
class DecodeScreen extends StatelessWidget {
  const DecodeScreen({super.key, this.onConvert});

  /// Hands the resolved code to the Convert tab — the "Rebuild with N live
  /// legs" action on a partly-dead slip.
  final void Function(String code)? onConvert;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SlipCubit>()),
        BlocProvider(create: (_) => getIt<PopularCodesCubit>()..load()),
      ],
      child: _DecodeView(onConvert: onConvert),
    );
  }
}

class _DecodeView extends StatefulWidget {
  const _DecodeView({this.onConvert});
  final void Function(String code)? onConvert;

  @override
  State<_DecodeView> createState() => _DecodeViewState();
}

class _DecodeViewState extends State<_DecodeView> {
  final _controller = TextEditingController();
  bool _copied = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decode(String raw) {
    final code = raw.trim().toUpperCase();
    if (code.isEmpty) return;
    context.read<SlipCubit>().resolve(code);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() => _controller.text = text.toUpperCase());
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _openBetway() =>
      launchUrl(Uri.parse(_betwayUrl), mode: LaunchMode.externalApplication);

  void _openShareSheet(BuildContext context, String code, double odds) {
    showAppBottomSheet(
      context: context,
      title: 'Share this code',
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShareCodeRow(code: code, odds: odds),
          const SizedBox(height: 10),
          const AppButton(
            label: 'WhatsApp',
            variant: AppButtonVariant.secondary,
            icon: 'message-circle',
            fullWidth: true,
          ),
          const SizedBox(height: 10),
          const AppButton(
            label: 'Telegram',
            variant: AppButtonVariant.secondary,
            icon: 'send',
            fullWidth: true,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Copy code and odds',
            variant: AppButtonVariant.secondary,
            icon: 'copy',
            fullWidth: true,
            onPressed: () => _copy(code),
          ),
        ],
      ),
      footerBuilder: (_) => AppButton(
        label: 'Open in Betway',
        variant: AppButtonVariant.primary,
        icon: 'external-link',
        fullWidth: true,
        onPressed: _openBetway,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlipCubit, SlipState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            CodeInput(
              controller: _controller,
              loading: state is SlipLoading,
              error: state is SlipError && state.failure is InvalidCodeFailure
                  ? "That's not a code we can read."
                  : null,
              onPaste: _paste,
              onSubmit: _decode,
            ),
            const SizedBox(height: 16),
            ...switch (state) {
              SlipInitial() => _buildInitial(context),
              SlipLoading() => const [SlipSkeleton(rows: 5)],
              SlipLoaded(:final slip) => _buildLoaded(context, slip),
              SlipError(:final failure) => _buildError(context, failure),
            },
          ],
        );
      },
    );
  }

  List<Widget> _buildInitial(BuildContext context) {
    return [
      const AppAlert(
        tone: AppAlertTone.info,
        icon: 'info',
        title: 'Paste any Betway booking code',
        body:
            "You'll see every selection, the market, the odds and whether the slip is still live — before you stake anything.",
      ),
      const SizedBox(height: 16),
      _PopularCodes(onUse: (c) => setState(() => _controller.text = c)),
    ];
  }

  List<Widget> _buildError(BuildContext context, Failure failure) {
    if (failure is InvalidCodeFailure) {
      return [
        AppAlert(
          tone: AppAlertTone.danger,
          title: "We can't read that code",
          body:
              'Codes are BW followed by 8 characters — like BW6E19810C. Check for an O typed as a 0, and drop any spaces.',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Clear',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
                icon: 'rotate-ccw',
                onPressed: () {
                  _controller.clear();
                  context.read<SlipCubit>().reset();
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Paste again',
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                icon: 'clipboard',
                onPressed: _paste,
              ),
            ],
          ),
        ),
      ];
    }

    // NetworkFailure / UnknownFailure: the code itself isn't the problem,
    // so this doesn't touch the input's own error slot (see `build`) —
    // just the transport failure's own message and a way to try again.
    return [
      AppAlert(
        tone: AppAlertTone.danger,
        title: 'Something went wrong',
        body: failure.message,
        action: AppButton(
          label: 'Try again',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          icon: 'rotate-ccw',
          onPressed: () => _decode(_controller.text),
        ),
      ),
    ];
  }

  List<Widget> _buildLoaded(BuildContext context, Slip slip) {
    final colors = context.colors;
    final dead = slip.selections.where((s) => !s.isActive).length;
    final live = slip.selections.length - dead;

    final footer = dead > 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppButton(
                label: 'Rebuild with $live live ${live == 1 ? 'leg' : 'legs'}',
                variant: AppButtonVariant.primary,
                icon: 'repeat',
                fullWidth: true,
                onPressed: widget.onConvert == null
                    ? null
                    : () => widget.onConvert!(slip.bookingCode),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Load as-is in Betway',
                variant: AppButtonVariant.ghost,
                icon: 'external-link',
                fullWidth: true,
                onPressed: _openBetway,
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Load in Betway',
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
                onPressed: () => _copy(slip.bookingCode),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Share',
                variant: AppButtonVariant.secondary,
                icon: 'share-2',
                onPressed: () =>
                    _openShareSheet(context, slip.bookingCode, slip.totalOdds),
              ),
            ],
          );

    return [
      SlipCard(
        code: slip.bookingCode,
        totalOdds: slip.totalOdds,
        // `slip.expiresAt` is always null coming back from `resolve`
        // (`docs/backend-api.md` §1) — there is no display string to build
        // from it. Not wired to a formatter yet for the same reason
        // `SlipHeader`'s `expiresIn` pill just doesn't render when this is
        // null: nothing produces a value to format today.
        expiresIn: null,
        usedCount: slip.usageCount,
        selections: slip.selections,
        collapsedCount: 5,
        onCopy: () => _copy(slip.bookingCode),
        footer: footer,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon('shield-check', size: 13, color: colors.textDisabled),
          const SizedBox(width: 8),
          Text(
            'Read-only. We never place bets for you.',
            style: AppTypography.meta.copyWith(color: colors.textDisabled),
          ),
        ],
      ),
    ];
  }
}

/// Live codes from `GET /api/booking-codes/popular` (`docs/backend-api.md`
/// §1) — the endpoint exists specifically to feed this empty state, so this
/// is the one section of the app that was never going to be a hardcoded
/// list. Failure here is quiet on purpose: this is a convenience, not the
/// thing the user came to do, so it degrades to nothing rather than an
/// alert competing with the actual decode flow above it.
class _PopularCodes extends StatelessWidget {
  const _PopularCodes({required this.onUse});
  final ValueChanged<String> onUse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<PopularCodesCubit, PopularCodesState>(
      builder: (context, state) {
        final body = switch (state) {
          PopularCodesLoading() => [
            for (var i = 0; i < 3; i++) ...[
              const _PopularCodeSkeleton(),
              const SizedBox(height: 8),
            ],
          ],
          PopularCodesError() => [
            Text(
              "Couldn't load codes to try right now.",
              style: AppTypography.meta.copyWith(color: colors.textMuted),
            ),
          ],
          PopularCodesLoaded(:final codes) when codes.isEmpty => [
            Text(
              'Nothing to try right now — paste a code above instead.',
              style: AppTypography.meta.copyWith(color: colors.textMuted),
            ),
          ],
          PopularCodesLoaded(:final codes) => [
            for (final slip in codes) ...[
              _PopularCodeTile(slip: slip, onUse: onUse),
              const SizedBox(height: 8),
            ],
          ],
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'POPULAR CODES',
              style: AppTypography.label.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 8),
            ...body,
          ],
        );
      },
    );
  }
}

class _PopularCodeSkeleton extends StatelessWidget {
  const _PopularCodeSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tone: AppCardTone.raised,
      padding: AppCardPadding.sm,
      radius: AppRadius.md,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                AppSkeleton(width: 120, height: 14),
                SizedBox(height: 8),
                AppSkeleton(width: 160, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const AppSkeleton(width: 16, height: 16, radius: AppRadius.xs),
        ],
      ),
    );
  }
}

/// One live code: a collapsed summary (code, odds, leg count) that expands
/// in place to the same [SelectionRow] list a resolved slip shows, with a
/// button to actually decode it. Replaces a plain tap-to-fill row — a
/// booking code alone tells a user nothing worth tapping for.
class _PopularCodeTile extends StatefulWidget {
  const _PopularCodeTile({required this.slip, required this.onUse});
  final Slip slip;
  final ValueChanged<String> onUse;

  @override
  State<_PopularCodeTile> createState() => _PopularCodeTileState();
}

class _PopularCodeTileState extends State<_PopularCodeTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final slip = widget.slip;
    final dead = slip.selections.where((s) => !s.isActive).length;

    return AppCard(
      tone: AppCardTone.raised,
      padding: AppCardPadding.none,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            label:
                'Booking code ${slip.bookingCode}, ${slip.selections.length} '
                'selections, odds ${slip.totalOdds.toStringAsFixed(2)}',
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  slip.bookingCode,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.code.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppBadge(
                                label: slip.totalOdds.toStringAsFixed(2),
                                tone: AppBadgeTone.accent,
                                mono: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: [
                              Text(
                                '${slip.selections.length} '
                                '${slip.selections.length == 1 ? 'selection' : 'selections'}',
                                style: AppTypography.meta.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                              if (dead > 0)
                                Text(
                                  '· $dead dead',
                                  style: AppTypography.meta.copyWith(
                                    color: colors.warnText,
                                  ),
                                ),
                              if (slip.expiresAt != null)
                                Text(
                                  '· ${formatExpiry(slip.expiresAt!)}',
                                  style: AppTypography.meta.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                              if (slip.usageCount != null)
                                Text(
                                  '· ${formatUsageCount(slip.usageCount!)} loaded',
                                  style: AppTypography.meta.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0,
                      duration: AppMotion.fast,
                      curve: AppMotion.easeOut,
                      child: AppIcon(
                        'chevron-right',
                        size: 16,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            Container(
              color: colors.surfaceRow,
              child: Column(
                children: [
                  for (var i = 0; i < slip.selections.length; i++)
                    SelectionRow(selection: slip.selections[i], index: i + 1),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: AppButton(
                label: 'Decode this code',
                variant: AppButtonVariant.secondary,
                icon: 'scan-line',
                fullWidth: true,
                onPressed: () => widget.onUse(slip.bookingCode),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShareCodeRow extends StatelessWidget {
  const _ShareCodeRow({required this.code, required this.odds});
  final String code;
  final double odds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashedRoundedBorder(
      color: colors.borderDashed,
      radius: AppRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              code,
              style: AppTypography.code.copyWith(color: colors.textPrimary),
            ),
            AppBadge(
              label: odds.toStringAsFixed(2),
              tone: AppBadgeTone.accent,
              mono: true,
            ),
          ],
        ),
      ),
    );
  }
}
