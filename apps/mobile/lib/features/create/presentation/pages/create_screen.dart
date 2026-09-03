import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../core/failure.dart';
import '../../../../design/tokens/app_colors.dart';
import '../../../../design/tokens/app_typography.dart';
import '../../../../design/widgets/app_alert.dart';
import '../../../../design/widgets/app_button.dart';
import '../../../../design/widgets/app_card.dart';
import '../../../../design/widgets/app_skeleton.dart';
import '../../../../widgets/slip/empty_state.dart';
import '../cubit/create_cubit.dart';
import '../cubit/create_state.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../widgets/created_code_view.dart';
import '../widgets/draft_tray.dart';
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
/// fixture list is reloaded whenever the selected sport changes, via the
/// [BlocListener] below — the one place the two screen-level cubits touch.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CreateCubit>()..load()),
        BlocProvider(create: (_) => getIt<EventsCubit>()),
      ],
      child: const _CreateView(),
    );
  }
}

class _CreateView extends StatelessWidget {
  const _CreateView();

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
        builder: (context, state) => switch (state) {
          CreateLoadingSports() => const _PickerSkeleton(),
          CreateSportsError(:final failure) => _SportsError(failure: failure),
          CreateReady() when state.createdCode != null => CreatedCodeView(
            state: state,
            onStartOver: () => context.read<CreateCubit>().startOver(),
          ),
          CreateReady() => _Picker(state: state),
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
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      children: [
        AppAlert(
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
        ),
      ],
    );
  }
}

/// The whole picker is one [CustomScrollView] rather than a `ListView` with a
/// `Column` of tiles inside it: the fixture list grows a page at a time via
/// "load more" and is genuinely unbounded, so its tiles build lazily as a
/// `SliverList.builder`. A chip tap still rebuilds this subtree (the draft
/// changed), but now only the tiles actually on screen rebuild with it.
class _Picker extends StatelessWidget {
  const _Picker({required this.state});
  final CreateReady state;

  @override
  Widget build(BuildContext context) {
    final createCubit = context.read<CreateCubit>();
    final selectedOutcomeIds = {for (final p in state.picks) p.outcomeId};
    final pickedEventIds = {for (final p in state.picks) p.eventId};
    final colors = context.colors;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              SportSelector(
                sports: state.sports,
                selectedId: state.selectedSport.id,
                onSelect: createCubit.selectSport,
              ),
              const SizedBox(height: 16),
              if (state.picks.isEmpty)
                const EmptyState(
                  icon: 'wand-sparkles',
                  title: 'Build a slip',
                  body:
                      'Tap the odds on any fixture below to add a leg. Open '
                      '"More markets" for totals, handicaps and the rest.',
                )
              else
                DraftTray(
                  state: state,
                  onRemove: createCubit.toggleOutcome,
                  onClear: createCubit.clearDraft,
                  onGenerate: createCubit.generate,
                  onRefreshEvents: () =>
                      context.read<EventsCubit>().load(state.selectedSport.id),
                ),
              const SizedBox(height: 20),
              Text(
                'UPCOMING',
                style: AppTypography.label.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        _EventsSliver(
          selectedOutcomeIds: selectedOutcomeIds,
          pickedEventIds: pickedEventIds,
          draftFull: state.isFull,
          sportName: state.selectedSport.name,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _EventsSliver extends StatelessWidget {
  const _EventsSliver({
    required this.selectedOutcomeIds,
    required this.pickedEventIds,
    required this.draftFull,
    required this.sportName,
  });

  final Set<String> selectedOutcomeIds;
  final Set<String> pickedEventIds;
  final bool draftFull;
  final String sportName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) => switch (state) {
        EventsLoading() => const SliverToBoxAdapter(
          child: _EventListSkeleton(),
        ),
        EventsError(:final failure) => SliverToBoxAdapter(
          child: AppAlert(
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
        ),
        EventsLoaded(:final events) when events.isEmpty => SliverToBoxAdapter(
          child: Text(
            'No upcoming $sportName fixtures right now.',
            style: AppTypography.meta.copyWith(color: colors.textMuted),
          ),
        ),
        EventsLoaded() => _EventListSliver(
          state: state,
          selectedOutcomeIds: selectedOutcomeIds,
          pickedEventIds: pickedEventIds,
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

class _EventListSliver extends StatelessWidget {
  const _EventListSliver({
    required this.state,
    required this.selectedOutcomeIds,
    required this.pickedEventIds,
    required this.draftFull,
  });

  final EventsLoaded state;
  final Set<String> selectedOutcomeIds;
  final Set<String> pickedEventIds;
  final bool draftFull;

  @override
  Widget build(BuildContext context) {
    final createCubit = context.read<CreateCubit>();
    final events = state.events;
    // One extra row for the "load more" footer when there is another page.
    final itemCount = events.length + (state.hasMore ? 1 : 0);

    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (i == events.length) return _LoadMore(state: state);
        final event = events[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: EventTile(
            event: event,
            selectedOutcomeIds: selectedOutcomeIds,
            draftFull: draftFull,
            eventHasPick: pickedEventIds.contains(event.eventId),
            onToggle: createCubit.toggleOutcome,
            onMoreMarkets: () => openMarketPickerSheet(context, event),
          ),
        );
      },
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
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      children: const [
        AppSkeleton(width: 48, height: 10),
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
