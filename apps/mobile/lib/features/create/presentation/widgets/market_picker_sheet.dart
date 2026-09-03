import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_bottom_sheet.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_skeleton.dart';
import '../../../../models/fixture.dart';
import '../cubit/create_cubit.dart';
import '../cubit/create_state.dart';
import '../cubit/event_markets_cubit.dart';
import '../cubit/event_markets_state.dart';
import '../model/draft_pick.dart';
import 'outcome_chip.dart';

/// Opens the "All markets" sheet for [event]. [CreateCubit] is passed down by
/// value because the sheet builds under the navigator, outside the Create
/// screen's provider scope; the market list gets its own throwaway
/// [EventMarketsCubit], created with the sheet and gone when it closes.
Future<void> openMarketPickerSheet(BuildContext context, Fixture event) {
  final createCubit = context.read<CreateCubit>();
  return showAppBottomSheet(
    context: context,
    title: event.name,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: createCubit),
        BlocProvider(
          create: (_) => getIt<EventMarketsCubit>()..load(event.eventId),
        ),
      ],
      child: _MarketPickerBody(event: event),
    ),
  );
}

class _MarketPickerBody extends StatelessWidget {
  const _MarketPickerBody({required this.event});
  final Fixture event;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventMarketsCubit, EventMarketsState>(
      builder: (context, state) {
        return switch (state) {
          EventMarketsLoading() => const _MarketsSkeleton(),
          EventMarketsEmpty() => const AppAlert(
            tone: AppAlertTone.info,
            title: 'No markets for this event yet',
            body:
                'Nothing is priced on this fixture right now. Try another event, '
                'or check back closer to kick-off.',
          ),
          EventMarketsError(:final failure) => AppAlert(
            tone: AppAlertTone.danger,
            title: "Couldn't load markets",
            body: failure.message,
            action: AppButton(
              label: 'Try again',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.sm,
              icon: 'rotate-ccw',
              onPressed: () =>
                  context.read<EventMarketsCubit>().load(event.eventId),
            ),
          ),
          EventMarketsLoaded(:final markets) =>
            BlocBuilder<CreateCubit, CreateState>(
              builder: (context, createState) {
                final selected = createState is CreateReady
                    ? {for (final p in createState.picks) p.outcomeId}
                    : const <String>{};
                final full = createState is CreateReady && createState.isFull;
                final eventHasPick =
                    createState is CreateReady &&
                    createState.picks.any((p) => p.eventId == event.eventId);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eventHasPick) ...[
                      const AppAlert(
                        tone: AppAlertTone.info,
                        title: 'One pick per match',
                        body:
                            "You've got a selection on this match. A booking code "
                            "can't combine two from the same event — remove it in "
                            'your slip to pick a different one.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    for (var i = 0; i < markets.length; i++) ...[
                      if (i > 0) const SizedBox(height: 18),
                      _MarketBlock(
                        event: event,
                        market: markets[i],
                        selectedOutcomeIds: selected,
                        draftFull: full,
                        eventHasPick: eventHasPick,
                      ),
                    ],
                  ],
                );
              },
            ),
        };
      },
    );
  }
}

class _MarketBlock extends StatelessWidget {
  const _MarketBlock({
    required this.event,
    required this.market,
    required this.selectedOutcomeIds,
    required this.draftFull,
    required this.eventHasPick,
  });

  final Fixture event;
  final Market market;
  final Set<String> selectedOutcomeIds;
  final bool draftFull;
  final bool eventHasPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          market.name,
          style: AppTypography.bodyStrong.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final outcome in market.outcomes)
              OutcomeChip(
                label: outcome.label,
                odds: outcome.odds,
                selected: selectedOutcomeIds.contains(outcome.outcomeId),
                disabled: draftFull || eventHasPick,
                onTap: () => context.read<CreateCubit>().toggleOutcome(
                  DraftPick.from(
                    event: event,
                    market: market,
                    outcome: outcome,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MarketsSkeleton extends StatelessWidget {
  const _MarketsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: 18),
          const AppSkeleton(width: 120, height: 13),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var j = 0; j < 3; j++) ...[
                if (j > 0) const SizedBox(width: 8),
                const AppSkeleton(width: 84, height: 34),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
