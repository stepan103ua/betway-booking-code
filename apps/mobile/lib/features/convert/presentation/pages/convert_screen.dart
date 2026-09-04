import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../core/failure.dart';
import '../../../../design/app_icons.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../design/widgets/app_reveal.dart';
import '../../../../widgets/slip/code_input.dart';
import '../../../../widgets/slip/slip_skeleton.dart';
import '../cubit/convert_cubit.dart';
import '../cubit/convert_state.dart';
import '../widgets/convert_leg_row.dart';
import '../widgets/convert_result_view.dart';

/// Convert: load a booking code, drop the legs you don't want (dead ones go
/// automatically), reissue it as a fresh code. Same four-layer skeleton as
/// `features/decode/` and `features/create/` (`docs/mobile.md` §2–§7), over
/// `POST /api/booking-codes/resolve` then `/convert`.
///
/// [initialCode] arrives from Decode's "Rebuild with N live legs" button — the
/// screen resolves it on open so the user lands straight on the picker.
class ConvertScreen extends StatelessWidget {
  const ConvertScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ConvertCubit>();
        final code = initialCode;
        if (code != null && code.isNotEmpty) cubit.resolve(code);
        return cubit;
      },
      child: _ConvertView(initialCode: initialCode),
    );
  }
}

class _ConvertView extends StatefulWidget {
  const _ConvertView({this.initialCode});
  final String? initialCode;

  @override
  State<_ConvertView> createState() => _ConvertViewState();
}

class _ConvertViewState extends State<_ConvertView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null) {
      _controller.text = widget.initialCode!.toUpperCase();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _load(String raw) {
    final code = raw.trim().toUpperCase();
    if (code.isEmpty) return;
    context.read<ConvertCubit>().resolve(code);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    setState(() => _controller.text = text.toUpperCase());
  }

  void _startOver() {
    _controller.clear();
    context.read<ConvertCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConvertCubit, ConvertState>(
      builder: (context, state) {
        final (String phaseKey, Widget child) = switch (state) {
          ConvertInitial(:final codeError) => (
            'input',
            _InputView(
              controller: _controller,
              codeError: codeError,
              onLoad: _load,
              onPaste: _paste,
              onClear: _startOver,
            ),
          ),
          ConvertResolving() => (
            'resolving',
            _ResolvingView(controller: _controller),
          ),
          ConvertReady() when state.result != null => (
            'result-${state.result!.bookingCode}',
            ConvertResultView(
              result: state.result!,
              onConvertAnother: _startOver,
            ),
          ),
          ConvertReady() => (
            'picker',
            _PickerView(state: state, onChangeCode: _startOver),
          ),
        };
        return AppReveal(key: ValueKey(phaseKey), child: child);
      },
    );
  }
}

// --- input ---------------------------------------------------------------

class _InputView extends StatelessWidget {
  const _InputView({
    required this.controller,
    required this.codeError,
    required this.onLoad,
    required this.onPaste,
    required this.onClear,
  });

  final TextEditingController controller;
  final Failure? codeError;
  final ValueChanged<String> onLoad;
  final VoidCallback onPaste;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final invalid = codeError is InvalidCodeFailure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CodeInput(
          controller: controller,
          cta: 'Load code',
          label: 'Booking code to convert',
          error: invalid ? "That's not a code we can read." : null,
          onPaste: onPaste,
          onSubmit: onLoad,
        ),
        const SizedBox(height: 16),
        if (codeError != null && !invalid)
          AppAlert(
            tone: AppAlertTone.danger,
            title: 'Something went wrong',
            body: codeError!.message,
            action: AppButton(
              label: 'Clear',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              icon: 'rotate-ccw',
              onPressed: onClear,
            ),
          )
        else
          const AppAlert(
            tone: AppAlertTone.info,
            icon: 'repeat',
            title: 'Rebuild a slip without its dead legs',
            body:
                'Load any booking code, drop the selections you no longer want '
                "— we'll remove ones that can't be bet anyway — and get a fresh "
                'code for what is left.',
          ),
      ],
    );
  }
}

class _ResolvingView extends StatelessWidget {
  const _ResolvingView({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        CodeInput(
          controller: controller,
          cta: 'Load code',
          label: 'Booking code to convert',
          loading: true,
          onSubmit: (_) {},
        ),
        const SizedBox(height: 16),
        const SlipSkeleton(rows: 5),
      ],
    );
  }
}

// --- picker -------------------------------------------------------------

class _PickerView extends StatelessWidget {
  const _PickerView({required this.state, required this.onChangeCode});

  final ConvertReady state;
  final VoidCallback onChangeCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cubit = context.read<ConvertCubit>();
    final selections = state.original.selections;
    final error = state.convertError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        _CodeHeader(code: state.original.bookingCode, onChange: onChangeCode),
        const SizedBox(height: 16),
        _DiffSummary(state: state),
        const SizedBox(height: 20),
        Text(
          'SELECTIONS',
          style: AppTypography.label.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: AppCardPadding.none,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in selections)
                AppReveal(
                  key: ValueKey(s.outcomeId),
                  child: ConvertLegRow(
                    selection: s,
                    dropped: !s.isActive || state.isDropped(s.outcomeId),
                    onToggle: s.isActive
                        ? () => cubit.toggleDrop(s.outcomeId)
                        : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (error != null) ...[
          _ConvertError(error: error),
          const SizedBox(height: 12),
        ],
        if (!state.canConvert) ...[
          Text(
            state.deadLegs.length == selections.length
                ? 'Every leg in this code is dead — there is nothing to rebuild.'
                : 'Keep at least one leg to convert.',
            style: AppTypography.meta.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 10),
        ],
        AppButton(
          label: 'Convert to a new code',
          variant: AppButtonVariant.primary,
          size: AppButtonSize.lg,
          icon: 'repeat',
          fullWidth: true,
          loading: state.converting,
          disabled: !state.canConvert,
          onPressed: cubit.convert,
        ),
      ],
    );
  }
}

class _CodeHeader extends StatelessWidget {
  const _CodeHeader({required this.code, required this.onChange});
  final String code;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONVERTING',
                style: AppTypography.label.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                code,
                style: AppTypography.codeHero.copyWith(
                  fontSize: 20,
                  color: colors.codeText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppButton(
          label: 'Change',
          variant: AppButtonVariant.ghost,
          size: AppButtonSize.sm,
          icon: 'rotate-ccw',
          onPressed: onChange,
        ),
      ],
    );
  }
}

class _DiffSummary extends StatelessWidget {
  const _DiffSummary({required this.state});
  final ConvertReady state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final kept = state.keptLegs.length;
    final dropped = state.droppedCount;

    return AppCard(
      tone: AppCardTone.sunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _OddsBlock(
                label: 'NOW',
                odds: state.original.totalOdds,
                legs: state.original.selections.length,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppIcon(
                  'chevron-right',
                  size: 18,
                  color: colors.textMuted,
                ),
              ),
              _OddsBlock(
                label: 'AFTER',
                odds: state.previewOdds,
                legs: kept,
                approximate: true,
                muted: !state.canConvert,
                // Pulses whenever a drop changes the preview total.
                replayKey: '${state.previewOdds}:$kept',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dropped == 0
                ? 'Nothing dropped yet — converting reissues the same bet.'
                : '$dropped ${dropped == 1 ? 'leg' : 'legs'} dropped. '
                      'Final odds are set when you convert — live prices differ '
                      'from these.',
            style: AppTypography.meta.copyWith(
              color: colors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OddsBlock extends StatelessWidget {
  const _OddsBlock({
    required this.label,
    required this.odds,
    required this.legs,
    this.approximate = false,
    this.muted = false,
    this.replayKey,
  });

  final String label;
  final double odds;
  final int legs;
  final bool approximate;
  final bool muted;

  /// When set, the odds figure fades-and-rises on every change of this value.
  final String? replayKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final oddsText = Text(
      '${approximate ? '≈ ' : ''}${odds.toStringAsFixed(2)}',
      style: AppTypography.odds.copyWith(
        fontSize: 18,
        color: muted ? colors.textDisabled : colors.oddsText,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 4),
        replayKey == null
            ? oddsText
            : AppReveal(key: ValueKey(replayKey), child: oddsText),
        const SizedBox(height: 2),
        Text(
          '$legs ${legs == 1 ? 'leg' : 'legs'}',
          style: AppTypography.meta.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _ConvertError extends StatelessWidget {
  const _ConvertError({required this.error});
  final Failure error;

  @override
  Widget build(BuildContext context) {
    final (title, tone) = switch (error) {
      EmptySlipFailure() => ('Nothing left to convert', AppAlertTone.warn),
      OutcomesUnavailableFailure() => (
        'Some selections went off',
        AppAlertTone.warn,
      ),
      ConflictingSelectionsFailure() => (
        'Two legs are on the same match',
        AppAlertTone.warn,
      ),
      _ => ("Couldn't convert", AppAlertTone.danger),
    };
    return AppAlert(tone: tone, title: title, body: error.message);
  }
}
