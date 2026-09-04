import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_bottom_sheet.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../widgets/slip/selection_row.dart';
import '../cubit/create_cubit.dart';
import '../cubit/create_state.dart';
import '../cubit/events_cubit.dart';

/// The full slip, opened from [DraftBar]. Legs with a remove control, the
/// running total, the generate/clear actions and any generate error — the
/// content that used to sit in a card pinned above the fixture list, moved
/// into a sheet so adding a leg never reflows the list underneath.
///
/// [CreateCubit] and [EventsCubit] are passed down by value: the sheet builds
/// under the navigator, outside the Create screen's provider scope — the same
/// pattern `openMarketPickerSheet` uses.
Future<void> openDraftSheet(BuildContext context) {
  final createCubit = context.read<CreateCubit>();
  final eventsCubit = context.read<EventsCubit>();
  return showAppBottomSheet(
    context: context,
    title: 'Your slip',
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: createCubit),
        BlocProvider.value(value: eventsCubit),
      ],
      child: const _DraftSheetBody(),
    ),
  );
}

class _DraftSheetBody extends StatelessWidget {
  const _DraftSheetBody();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<CreateCubit, CreateState>(
      // Close the sheet once there is nothing left to show it for — the last
      // leg removed, or a code generated (the screen swaps to the recap).
      listenWhen: (prev, curr) =>
          curr is! CreateReady ||
          curr.picks.isEmpty ||
          curr.createdCode != null,
      listener: (context, _) => Navigator.of(context).maybePop(),
      builder: (context, state) {
        if (state is! CreateReady || state.picks.isEmpty) {
          return const SizedBox.shrink();
        }
        final cubit = context.read<CreateCubit>();
        final picks = state.picks;
        final error = state.generateError;

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      '${picks.length} ${picks.length == 1 ? 'leg' : 'legs'}',
                      style: AppTypography.meta.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TOTAL ODDS',
                        style: AppTypography.label.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.totalOdds.toStringAsFixed(2),
                        style: AppTypography.oddsHero.copyWith(
                          color: colors.oddsText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < picks.length; i++)
                SelectionRow(
                  selection: picks[i].toSelection(),
                  index: i + 1,
                  onRemove: () => cubit.toggleOutcome(picks[i]),
                ),
              const SizedBox(height: 16),
              if (error != null) ...[
                _GenerateError(
                  error: error,
                  onRefreshEvents: () {
                    context.read<EventsCubit>().load(state.selectedSport.id);
                  },
                ),
                const SizedBox(height: 12),
              ],
              if (state.isFull) ...[
                Text(
                  'Maximum $kMaxDraftPicks legs — remove one to add another.',
                  style: AppTypography.meta.copyWith(color: colors.textMuted),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  AppButton(
                    label: 'Clear',
                    variant: AppButtonVariant.ghost,
                    icon: 'rotate-ccw',
                    onPressed: state.generating ? null : cubit.clearDraft,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      label: 'Generate code',
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.lg,
                      icon: 'wand-sparkles',
                      fullWidth: true,
                      loading: state.generating,
                      onPressed: cubit.generate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GenerateError extends StatelessWidget {
  const _GenerateError({required this.error, required this.onRefreshEvents});
  final Failure error;
  final VoidCallback onRefreshEvents;

  @override
  Widget build(BuildContext context) {
    if (error is OutcomesUnavailableFailure) {
      return AppAlert(
        tone: AppAlertTone.warn,
        title: 'Some selections went off',
        body: error.message,
        action: AppButton(
          label: 'Refresh fixtures',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.sm,
          icon: 'rotate-ccw',
          onPressed: onRefreshEvents,
        ),
      );
    }
    // TooManyOutcomesFailure (shouldn't reach — capped client-side),
    // NetworkFailure, UnknownFailure: state the message, offer nothing beyond
    // retrying the button below.
    return AppAlert(
      tone: AppAlertTone.danger,
      title: "Couldn't generate a code",
      body: error.message,
    );
  }
}
