'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import type { EventsPage, Fixture, Sport } from '@booking-code/contracts';
import { RotateCcw, WandSparkles } from 'lucide-react';
import { CreatedCode } from '@/components/create/created-code';
import { DraftTray } from '@/components/create/draft-tray';
import { EventList } from '@/components/create/event-list';
import { MarketPickerDialog } from '@/components/create/market-picker-dialog';
import { SportSelector } from '@/components/create/sport-selector';
import { Alert } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { EmptyState } from '@/components/ui/empty-state';
import type { CreateResult } from '@/lib/create';
import { type DraftPick, togglePick } from '@/lib/draft';
import { generateCode } from '@/app/actions';

/**
 * Create's whole client surface — the port of apps/mobile's `CreateScreen` + its three
 * cubits. Draft picks and the market sheet are local state; the fixture list pages itself
 * (`EventList`); generate is the `generateCode` Server Action run inside a transition. The
 * selected sport lives in `?sport=` (server-fetched), so switching sport is a navigation
 * that clears the draft.
 */
export function CreateScreen({
  sports,
  sport,
  firstEventsPage,
}: {
  sports: Sport[] | null;
  sport: string | null;
  firstEventsPage: EventsPage | null;
}) {
  const router = useRouter();
  const [picks, setPicks] = useState<DraftPick[]>([]);
  const [marketEvent, setMarketEvent] = useState<Fixture | null>(null);
  const [dismissed, setDismissed] = useState(false);
  const [result, setResult] = useState<CreateResult | null>(null);
  const [pending, startTransition] = useTransition();

  function generate() {
    setDismissed(false);
    startTransition(async () => {
      setResult(await generateCode(picks.map((p) => p.outcomeId)));
    });
  }

  // A fresh sport starts a fresh slip (docs/mobile.md — CreateCubit.selectSport).
  const [prevSport, setPrevSport] = useState(sport);
  if (sport !== prevSport) {
    setPrevSport(sport);
    setPicks([]);
    setDismissed(false);
  }

  if (!sports || sports.length === 0 || !sport) {
    return (
      <Alert
        tone="danger"
        title="Couldn't start Create"
        action={
          <Button
            variant="secondary"
            size="sm"
            icon={<RotateCcw className="size-3.5" aria-hidden />}
            onClick={() => startTransition(() => router.refresh())}
          >
            Try again
          </Button>
        }
      >
        No sports are available right now.
      </Alert>
    );
  }

  const created = !dismissed && result?.kind === 'created' ? result : undefined;
  const genError = !dismissed && result && result.kind !== 'created' ? result : undefined;
  const selectedOutcomeIds = new Set(picks.map((p) => p.outcomeId));
  const pickedEventIds = new Set(picks.map((p) => p.eventId));
  const draftFull = picks.length >= 20;

  function toggle(pick: DraftPick) {
    setPicks((p) => togglePick(p, pick));
    setDismissed(true);
  }

  if (created) {
    return (
      <CreatedCode
        bookingCode={created.bookingCode}
        picks={picks}
        onStartOver={() => {
          setPicks([]);
          setResult(null);
        }}
      />
    );
  }

  return (
    <div className="flex animate-rise flex-col gap-4 pb-6">
      <SportSelector sports={sports} selectedId={sport} />

      <div key={picks.length === 0 ? 'empty' : 'tray'} className="animate-rise">
        {picks.length === 0 ? (
          <EmptyState
            icon={<WandSparkles className="size-[22px]" aria-hidden />}
            title="Build a slip"
            body='Tap the odds on any fixture below to add a leg. Open "More markets" for totals, handicaps and the rest.'
          />
        ) : (
          <DraftTray
            picks={picks}
            error={genError}
            generating={pending}
            onRemove={toggle}
            onClear={() => setPicks([])}
            onGenerate={generate}
            onRefreshEvents={() => startTransition(() => router.refresh())}
          />
        )}
      </div>

      <div className="flex flex-col gap-2.5">
        <h2 className="type-label text-text-muted">Upcoming</h2>
        <EventList
          sport={sport}
          sportName={sports.find((s) => s.id === sport)?.name ?? 'soccer'}
          firstPage={firstEventsPage}
          selectedOutcomeIds={selectedOutcomeIds}
          pickedEventIds={pickedEventIds}
          draftFull={draftFull}
          onToggle={toggle}
          onMoreMarkets={setMarketEvent}
        />
      </div>

      <MarketPickerDialog
        event={marketEvent}
        selectedOutcomeIds={selectedOutcomeIds}
        draftFull={draftFull}
        eventHasPick={marketEvent ? pickedEventIds.has(marketEvent.eventId) : false}
        onToggle={toggle}
        onClose={() => setMarketEvent(null)}
      />
    </div>
  );
}
