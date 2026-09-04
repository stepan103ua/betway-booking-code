import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/failure.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../design/widgets/app_expandable.dart';
import '../../../../design/widgets/app_reveal.dart';
import '../../../../design/widgets/app_skeleton.dart';
import '../../../../widgets/slip/empty_state.dart';
import '../cubit/create_cubit.dart';
import '../cubit/create_state.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../model/draft_pick.dart';
import '../widgets/created_code_view.dart';
import '../widgets/event_tile.dart';
import '../widgets/market_picker_sheet.dart';
import '../widgets/sport_selector.dart';

/// Create: build an accumulator from scratch and generate a booking code.
/// Same four-layer, feature-first skeleton `features/decode/` has
/// (`docs/mobile.md` §2–§7), wired to `GET /api/sports`, `GET /api/events`,
/// `GET /api/events/:id/markets` and `POST /api/booking-codes`.
///
/// Three cubits: [CreateCubit] (sports + draft + generate), [EventsCubit]
/// (the paginated fixture list), and a per-sheet `EventMarketsCubit`. The
/// [CreateCubit] / [EventsCubit] providers are created by `AppShell` so the
/// floating `DraftBar` in its overlay shares them; this widget is just the
/// scrolling content. The fixture list reloads whenever the selected sport
/// changes, via the [BlocListener] below.
class CreateView extends StatelessWidget {
  const CreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCubit, CreateState>(
      listenWhen: (prev, curr) =>
          curr is CreateReady &&
          (prev is! CreateReady ||
              prev.selectedSport.id != curr.selectedSport.id),
      listener: (context, state) {
        state as CreateReady;
        context.read<EventsCubit>().load(state.selectedSport.id);
      },
      child: BlocBuilder<CreateCubit, CreateState>(
        builder: (context, state) {
          final (String phaseKey, Widget child) = switch (state) {
            CreateLoadingSports() => ('loading', const _PickerSkeleton()),
            CreateSportsError(:final failure) => (
              'error',
              _SportsError(failure: failure),
            ),
            CreateReady() when state.createdCode != null => (
              'created-${state.createdCode}',
              CreatedCodeView(
                state: state,
                onStartOver: () => context.read<CreateCubit>().startOver(),
              ),
            ),
            // Sport id in the key so switching sport replays the reveal — the
            // web keys this subtree on the sport the same way.
            CreateReady() => (
              'picker-${state.selectedSport.id}',
              _Picker(state: state),
            ),
          };
          return AppReveal(key: ValueKey(phaseKey), child: child);
        },
      ),
    );
  }
}

class _SportsError extends StatelessWidget {
  const _SportsError({required this.failure});
  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return AppAlert(
      tone: AppAlertTone.danger,
      title: "Couldn't start Create",
      body: failure.message,
      action: AppButton(
        label: 'Try again',
        variant: AppButtonVariant.secondary,
        size: AppButtonSize.sm,
        icon: 'rotate-ccw',
        onPressed: () => context.read<CreateCubit>().load(),
      ),
    );
  }
}

/// The picker is a plain `Column` — `AppShell` owns the one page scroll, so
/// nothing here scrolls on its own. The fixture list grows a page at a time
/// via "load more"; its rows build eagerly (the web renders the whole list
/// too, and a user only ever pulls in a handful of pages).
class _Picker extends StatelessWidget {
  const _Picker({required this.state});
  final CreateReady state;

  @override
  Widget build(BuildContext context) {
    final createCubit = context.read<CreateCubit>();
    final picksByEvent = {for (final p in state.picks) p.eventId: p};
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        SportSelector(
          sports: state.sports,
          selectedId: state.selectedSport.id,
          onSelect: createCubit.selectSport,
        ),
        // The "how to build a slip" hint collapses away once there's a leg —
        // the running slip lives in the floating `DraftBar` from then on, not
        // in a card here, so the fixture list never reflows on a pick.
        AppExpandable(
          expanded: state.picks.isEmpty,
          child: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: EmptyState(
              icon: 'wand-sparkles',
              title: 'Build a slip',
              body:
                  'Tap the odds on any fixture below to add a leg. Open '
                  '"More markets" for totals, handicaps and the rest.',
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'UPCOMING',
          style: AppTypography.label.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 10),
        _EventsList(
          picksByEvent: picksByEvent,
          draftFull: state.isFull,
          sportName: state.selectedSport.name,
        ),
        // Clearance for the floating `DraftBar` so "load more" / the last
        // fixture stay reachable above it.
        AppExpandable(
          expanded: state.picks.isNotEmpty,
          child: const SizedBox(height: 76),
        ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.picksByEvent,
    required this.draftFull,
    required this.sportName,
  });

  final Map<String, DraftPick> picksByEvent;
  final bool draftFull;
  final String sportName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) => switch (state) {
        EventsLoading() => const _EventListSkeleton(),
        EventsError(:final failure) => AppAlert(
          tone: AppAlertTone.danger,
          title: "Couldn't load fixtures",
          body: failure.message,
          action: AppButton(
            label: 'Try again',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.sm,
            icon: 'rotate-ccw',
            onPressed: () => _reload(context),
          ),
        ),
        EventsLoaded(:final events) when events.isEmpty => Text(
          'No upcoming $sportName fixtures right now.',
          style: AppTypography.meta.copyWith(color: colors.textMuted),
        ),
        EventsLoaded() => _EventListColumn(
          state: state,
          picksByEvent: picksByEvent,
          draftFull: draftFull,
        ),
      },
    );
  }

  void _reload(BuildContext context) {
    final createState = context.read<CreateCubit>().state;
    if (createState is CreateReady) {
      context.read<EventsCubit>().load(createState.selectedSport.id);
    }
  }
}

class _EventListColumn extends StatelessWidget {
  const _EventListColumn({
    required this.state,
    required this.picksByEvent,
    required this.draftFull,
  });

  final EventsLoaded state;
  final Map<String, DraftPick> picksByEvent;
  final bool draftFull;

  @override
  Widget build(BuildContext context) {
    final createCubit = context.read<CreateCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final event in state.events)
          AppReveal(
            // Keyed by event so a "load more" only animates the appended tiles.
            key: ValueKey(event.eventId),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EventTile(
                event: event,
                pick: picksByEvent[event.eventId],
                draftFull: draftFull,
                onToggle: createCubit.toggleOutcome,
                onMoreMarkets: () => openMarketPickerSheet(context, event),
              ),
            ),
          ),
        if (state.hasMore) _LoadMore(state: state),
      ],
    );
  }
}

class _LoadMore extends StatelessWidget {
  const _LoadMore({required this.state});
  final EventsLoaded state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.loadMoreError != null) ...[
            Text(
              '${state.loadMoreError!.message} Tap to try again.',
              style: AppTypography.meta.copyWith(
                color: context.colors.dangerText,
              ),
            ),
            const SizedBox(height: 8),
          ],
          AppButton(
            label: state.loadMoreError != null
                ? 'Retry loading fixtures'
                : 'Load more fixtures',
            variant: AppButtonVariant.secondary,
            icon: 'chevron-right',
            fullWidth: true,
            loading: state.loadingMore,
            onPressed: () => context.read<EventsCubit>().loadMore(),
          ),
        ],
      ),
    );
  }
}

// --- loading placeholders -------------------------------------------------

class _PickerSkeleton extends StatelessWidget {
  const _PickerSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: AppSkeleton(width: 48, height: 10),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            AppSkeleton(width: 96, height: 36, radius: 999),
            SizedBox(width: 8),
            AppSkeleton(width: 96, height: 36, radius: 999),
          ],
        ),
        SizedBox(height: 24),
        _EventListSkeleton(),
      ],
    );
  }
}

class _EventListSkeleton extends StatelessWidget {
  const _EventListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                AppSkeleton(height: 13),
                SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  alignment: Alignment.centerLeft,
                  child: AppSkeleton(height: 10),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: AppSkeleton(height: 34)),
                    SizedBox(width: 8),
                    Expanded(child: AppSkeleton(height: 34)),
                    SizedBox(width: 8),
                    Expanded(child: AppSkeleton(height: 34)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
